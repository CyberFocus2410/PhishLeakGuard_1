# PhishLeak Guard - Deployment Guide

## Firebase Cloud Functions Setup

The breach detection feature uses a Firebase Cloud Function to avoid CORS issues when calling the HaveIBeenPwned API from the browser.

### Prerequisites

1. **HaveIBeenPwned API Key**: Get your free API key from https://haveibeenpwned.com/API/Key
   - Cost: $3.50 USD per month (supports unlimited API calls)
   - This is required for the breach checking feature to work

### Deployment Steps

#### 1. Install Firebase CLI

```bash
npm install -g firebase-tools
```

#### 2. Login to Firebase

```bash
firebase login
```

#### 3. Initialize Firebase Functions (if not already done)

```bash
firebase init functions
```

Select:
- Use an existing project (select your Firebase project)
- TypeScript
- Yes to ESLint
- Yes to install dependencies

#### 4. Install Function Dependencies

```bash
cd functions
npm install
```

#### 5. Set the HaveIBeenPwned API Key

```bash
firebase functions:config:set hibp.api_key="YOUR_API_KEY_HERE"
```

Replace `YOUR_API_KEY_HERE` with your actual API key from HaveIBeenPwned.

**IMPORTANT**: In the code, this is accessed as `process.env.HIBP_API_KEY`, so when deploying, set it as an environment variable:

```bash
firebase functions:secrets:set HIBP_API_KEY
```

Then paste your API key when prompted.

#### 6. Deploy the Function

```bash
firebase deploy --only functions
```

This will deploy the `checkEmailBreach` function to Firebase.

#### 7. Verify Deployment

After deployment, you should see output like:
```
✔  functions[checkEmailBreach(us-central1)] Successful create operation.
Function URL (checkEmailBreach): https://us-central1-YOUR_PROJECT.cloudfunctions.net/checkEmailBreach
```

### Testing

1. Open your app in Dreamflow
2. Go to the "Leak Watch" page
3. Enter an email address (try a known compromised email like "test@adobe.com")
4. Click "Check for Breaches"
5. You should see breach results if the email has been compromised

### Environment Variables Summary

**Name**: `HIBP_API_KEY`
**Description**: API key for HaveIBeenPwned breach checking service
**Where to get it**: https://haveibeenpwned.com/API/Key
**Cost**: $3.50 USD/month

### Troubleshooting

1. **"API key not configured" error**
   - Make sure you've set the `HIBP_API_KEY` secret using `firebase functions:secrets:set HIBP_API_KEY`
   - Redeploy the function after setting the secret

2. **"Rate limit exceeded" error**
   - HaveIBeenPwned API has rate limits
   - Wait a few moments and try again
   - Consider implementing caching for frequent queries

3. **Function not found**
   - Make sure the function is deployed: `firebase deploy --only functions`
   - Check the Firebase Console > Functions to verify the function exists

4. **CORS errors**
   - The Cloud Function should handle CORS automatically
   - If issues persist, check the Firebase Console logs for errors

### Local Development

To test functions locally:

```bash
cd functions
npm run serve
```

This starts the Firebase emulator suite. Update your Flutter app to point to the local emulator:

```dart
// In your app initialization
FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
```

### Cost Considerations

- **HaveIBeenPwned API**: $3.50 USD/month
- **Firebase Cloud Functions**: 
  - Free tier: 2M invocations/month
  - After free tier: $0.40 per million invocations
  - For typical usage, this should stay within the free tier

### Security Notes

- The API key is stored as a Firebase secret and never exposed to the client
- All API calls go through your Firebase project, preventing direct exposure
- User emails are validated before being sent to the API
- Rate limiting is handled at both the API and Firebase levels
