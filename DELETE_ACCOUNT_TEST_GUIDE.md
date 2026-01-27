# 🧪 Delete Account Feature - Testing Guide

## 📋 What Was Fixed

### Changes Made:
1. ✅ Changed HTTP method from `POST` to `DELETE` in `auth_provider.dart`
2. ✅ Added debug logging to track token and API response
3. ✅ Connected Delete button in Profile screen to actual API
4. ✅ Added proper error handling and navigation

---

## 🔧 Pre-Testing Checklist

### 1. **Verify Your Backend API**
Before testing, confirm with your backend team:
- ✅ Endpoint: `DELETE https://travolyo.com/api/delete-my-account`
- ✅ Requires: `Authorization: Bearer {token}` header
- ✅ Expected success response format

### 2. **Clean Build** (Important!)
```bash
# Run these commands in terminal:
flutter clean
flutter pub get
flutter run
```

---

## 🧪 Testing Steps

### **Test 1: Check Token Storage**

1. **Login to your app**
2. **Open Debug Console** (in VS Code or Android Studio)
3. **Look for login logs** - You should see:
   ```
   Token saved: eyJ0eXAiOiJKV1QiLCJhbGc...
   ```

4. **Verify token is stored:**
   - Navigate to Profile screen
   - Check console for token retrieval
   - Should NOT see "NO TOKEN"

---

### **Test 2: Test Delete Account Flow**

#### Step-by-Step:

1. **Navigate to Profile Screen**
   - Open your app
   - Go to Profile/Account tab

2. **Tap "Delete Account"** (red menu item above Logout)

3. **Verify Confirmation Dialog Appears:**
   - ✅ Title: "Delete Account" (in red)
   - ✅ Message: "This action is permanent and cannot be undone."
   - ✅ Two buttons: "Cancel" and "Delete"

4. **Tap "Cancel"** (first test)
   - ✅ Dialog should close
   - ✅ No API call should be made
   - ✅ User stays on Profile screen

5. **Tap "Delete Account" Again**

6. **Tap "Delete" Button** (this time)
   - ✅ Dialog closes
   - ✅ "Deleting account..." message appears

7. **Monitor Console Logs:**
   ```
   Token being sent: eyJ0eXAiOiJKV1QiLCJhbGc...
   Delete account response: {success: true, data: {...}}
   ```

8. **Expected Outcomes:**

   **If Successful:**
   - ✅ Success toast message appears
   - ✅ App navigates to Sign In screen
   - ✅ SharedPreferences cleared
   - ✅ User is logged out

   **If Failed:**
   - ❌ Error toast appears
   - ❌ User stays on Profile screen
   - ❌ Check console for error details

---

## 🐛 Debugging Common Issues

### Issue 1: "NO TOKEN" in console
**Solution:**
```dart
// Check if user is logged in first
// Go to Sign In screen and login again
// Token is saved during login
```

### Issue 2: Still getting "Unauthorized access"
**Possible Causes:**
1. Backend doesn't accept DELETE method → Contact backend team
2. Token expired → Login again
3. Backend route misconfigured → Check backend logs

**How to verify:**
- Check console log: `Token being sent: {token}`
- If token shows properly, issue is backend
- If "NO TOKEN", issue is frontend login flow

### Issue 3: App crashes when tapping Delete
**Solution:**
- Check console for error stack trace
- Verify imports in profile_screen.dart
- Run `flutter clean && flutter pub get`

---

## 📱 Manual Testing Checklist

- [ ] Login with valid credentials
- [ ] Navigate to Profile screen
- [ ] Verify "Delete Account" appears above Logout (in red)
- [ ] Tap "Delete Account"
- [ ] Verify confirmation dialog appears
- [ ] Tap "Cancel" - dialog should close
- [ ] Tap "Delete Account" again
- [ ] Tap "Delete" button
- [ ] Verify "Deleting account..." message shows
- [ ] Monitor console for:
  - [ ] Token log: `Token being sent: ...`
  - [ ] Response log: `Delete account response: ...`
- [ ] Verify appropriate outcome:
  - [ ] Success → Navigates to Sign In screen
  - [ ] Error → Shows error message

---

## 🔍 How to Check Console Logs

### In VS Code:
1. Open **Debug Console** tab (bottom panel)
2. Run app with F5 or `flutter run`
3. All logs appear in Debug Console

### In Android Studio:
1. Open **Run** tab (bottom panel)
2. Click on **Flutter** console
3. All logs appear there

### In Terminal:
```bash
# Run app and see logs
flutter run -v

# Filter for specific logs
flutter run | grep -i "token\|delete"
```

---

## 📊 Expected API Request

When you tap "Delete", this request is sent:

```http
DELETE /api/delete-my-account HTTP/1.1
Host: travolyo.com
Content-Type: application/json
Accept-Language: en
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

---

## ✅ Success Criteria

The feature is working correctly if:

1. ✅ Token is logged in console (not "NO TOKEN")
2. ✅ API request shows DELETE method (not POST)
3. ✅ Authorization header is sent
4. ✅ Backend responds with success
5. ✅ User is redirected to Sign In screen
6. ✅ All SharedPreferences are cleared

---

## 🆘 If It Still Fails

### Check These:

1. **Backend Response Format:**
   ```json
   // Your backend should return this on success:
   {
     "success": true,
     "data": {
       "message": "Account deleted successfully"
     }
   }
   ```

2. **Backend Route Configuration:**
   - Ask backend team to verify DELETE route exists
   - Check if route requires additional parameters
   - Verify authentication middleware is working

3. **Share Console Logs:**
   - Copy full console output
   - Share with backend team
   - Include both "Token being sent" and "response" logs

---

## 📞 Need More Help?

If testing fails, provide:
1. Screenshot of console logs
2. Full error message (if any)
3. Backend API documentation
4. Response from backend team about the endpoint

---

## 🎯 Quick Test Command

Run this in terminal to test with verbose logging:

```bash
# Clean and run with logs
flutter clean && flutter pub get && flutter run -v | grep -E "Token|Delete|response"
```

---

**Last Updated:** January 26, 2026
**Status:** ✅ Ready for Testing
