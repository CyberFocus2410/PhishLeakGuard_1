import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as crypto from 'crypto';

admin.initializeApp();

/**
 * Cloud Function to check if an email has been in data breaches
 * Uses XposedOrNot API - Free and no API key required!
 * API: https://xposedornot.com/
 */
export const checkEmailBreach = functions.https.onCall(async (data, context) => {
  // Validate input
  const email = data.email;
  if (!email || typeof email !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Email is required');
  }

  // Validate email format
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid email format');
  }

  try {
    // Import node-fetch dynamically
    const fetch = (await import('node-fetch')).default;

    // Call XposedOrNot API - No API key needed!
    const url = `https://api.xposedornot.com/v1/check-email/${encodeURIComponent(email)}`;
    
    const response = await fetch(url, {
      headers: {
        'User-Agent': 'PhishLeakGuard-App',
      },
    });

    // Handle different response codes
    if (response.status === 404) {
      // No breaches found - good news!
      return {
        success: true,
        isCompromised: false,
        breachCount: 0,
        breaches: [],
      };
    }

    if (response.status === 429) {
      throw new functions.https.HttpsError(
        'resource-exhausted',
        'Rate limit exceeded. Please try again later.'
      );
    }

    if (response.status !== 200) {
      const errorText = await response.text();
      console.error(`API error: ${response.status} - ${errorText}`);
      throw new functions.https.HttpsError(
        'internal',
        `API returned status ${response.status}`
      );
    }

    // Parse response
    const result = await response.json();
    
    // XposedOrNot returns data in format:
    // {
    //   "ExposedBreaches": {
    //     "breaches_details": [...],
    //     "breaches_count": number
    //   }
    // }
    
    const exposedBreaches = result.ExposedBreaches || {};
    const breachesDetails = exposedBreaches.breaches_details || [];
    const breachCount = exposedBreaches.breaches_count || 0;

    if (breachCount === 0 || breachesDetails.length === 0) {
      return {
        success: true,
        isCompromised: false,
        breachCount: 0,
        breaches: [],
      };
    }
    
    // Transform the data to our format
    const transformedBreaches = breachesDetails.map((breach: any) => ({
      name: breach.breach || 'Unknown',
      domain: breach.domain || '',
      breachDate: breach.breach_date || new Date().toISOString().split('T')[0],
      affectedAccounts: breach.exposedrecords || 0,
      dataTypes: breach.compromised_data || [],
      severity: calculateSeverity(breach.compromised_data || []),
      description: breach.details || breach.breach || '',
    }));

    return {
      success: true,
      isCompromised: true,
      breachCount: transformedBreaches.length,
      breaches: transformedBreaches,
    };
  } catch (error: any) {
    console.error('Error checking breaches:', error);
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError(
      'internal',
      'Failed to check breaches. Please try again later.'
    );
  }
});

/**
 * Calculate severity based on compromised data types
 */
function calculateSeverity(dataTypes: string[]): string {
  const criticalTypes = ['passwords', 'credit cards', 'bank account numbers', 'passport numbers'];
  const highTypes = ['email addresses', 'phone numbers', 'social security numbers'];
  
  const dataTypesLower = dataTypes.map(t => t.toLowerCase());
  
  if (dataTypesLower.some(type => criticalTypes.some(critical => type.includes(critical)))) {
    return 'Critical';
  }
  
  if (dataTypesLower.some(type => highTypes.some(high => type.includes(high)))) {
    return 'High';
  }
  
  return 'Medium';
}
