# WebSocket Debugging Guide

## Issues Fixed in Code

### 1. **Connection State Management**
- ✅ Fixed: Connection state now properly waits for actual connection
- ✅ Added: Connection confirmation when first message is received
- ✅ Added: Better connection retry logic

### 2. **Message Handling**
- ✅ Improved: Better JSON parsing with error handling
- ✅ Added: Comprehensive logging for debugging
- ✅ Added: Listener status checking

### 3. **Subscription Management**
- ✅ Fixed: Proper subscription cleanup before creating new one
- ✅ Added: Better timing for subscription setup

## Potential Backend Issues to Check

### 1. **WebSocket URL and Authentication**
Check if backend expects:
- ✅ Token in headers: `Authorization: Bearer <token>` (Currently implemented)
- ❓ Token in query parameter: `ws://192.168.75.96:3000/ws?token=<token>`
- ❓ Token in first message: `{"type": "auth", "token": "<token>"}` (Currently sending)

**Action**: Verify with backend team which authentication method is used.

### 2. **Message Format from Backend**
The code expects messages in this format:
```json
{
  "type": "conversation_updated" | "receive_message" | "messages_read",
  "data": {
    "conversation": [...] // Array of messages
    // OR
    "message": {...} // Single message object
  }
}
```

**Check Backend**:
- Does backend send `type` field in WebSocket messages?
- Is the structure `message.data.conversation` or `message.data.message`?
- Are field names in `snake_case` (sender_id, receiver_id) or `camelCase` (senderId, receiverId)?

### 3. **Event Types**
Backend should send these event types:
- `conversation_updated` - When any message is sent/received
- `receive_message` - When a new message is received
- `messages_read` - When messages are marked as read

**Action**: Verify backend is sending these exact event type strings.

### 4. **WebSocket Connection**
**Check**:
- Is WebSocket server running on `ws://192.168.75.96:3000/ws`?
- Does it accept connections with Authorization header?
- Does it send messages immediately after connection?

## Debugging Steps

### Step 1: Check WebSocket Connection
Look for these logs in console:
```
WebSocket: Attempting to connect to ws://192.168.75.96:3000/ws
WebSocket: ✅ Connection established (optimistic)
WebSocket: ✅ Connection confirmed (received first message)
ConversationScreen: ✅ Socket connected successfully
```

**If you see errors**:
- `WebSocket: ⚠️ Error: ...` - Connection failed
- `WebSocket: ❌ Connection closed` - Connection dropped

### Step 2: Check Message Reception
Look for these logs:
```
WebSocket: 📨 Received message (keys: [...])
WebSocket: ✅ Event type detected: conversation_updated
ConversationScreen: 📨 Received WebSocket data
ConversationScreen: ✅ Event type detected: conversation_updated
```

**If messages are received but not processed**:
- Check if event type matches exactly
- Check if data structure matches expected format

### Step 3: Check Event Processing
Look for:
```
ConversationScreen: Handling conversation_updated event
ConversationScreen: Found conversation list with X items
ConversationScreen: ✅ Updating conversation with X messages
```

**If you see**:
- `ConversationScreen: ⚠️ Conversation data structure not recognized` - Backend format mismatch
- `ConversationScreen: ⏭️ Conversation not relevant to this screen` - Message is for different conversation

## Testing Checklist

### Test 1: Connection
- [ ] Open conversation screen
- [ ] Check console for "Socket connected successfully"
- [ ] Verify WebSocket connection is active

### Test 2: Receive Message
- [ ] Keep conversation screen open
- [ ] Send message from another device
- [ ] Check console logs for:
  - `WebSocket: 📨 Received message`
  - `ConversationScreen: 📨 Received WebSocket data`
  - `ConversationScreen: Handling conversation_updated event` OR `Handling receive_message event`
  - `ConversationScreen: ✅ Updating conversation`

### Test 3: Message Format
If messages are received but not displayed:
- [ ] Check console for full message structure
- [ ] Verify `event_type` or `type` field exists
- [ ] Verify `data.conversation` or `data.message` structure
- [ ] Check if field names match (sender_id vs senderId)

## Backend API Verification

Ask backend team to verify:

1. **WebSocket Endpoint**
   - URL: `ws://192.168.75.96:3000/ws`
   - Authentication method (header, query param, or message)

2. **Message Format**
   - Event type field name: `type`, `event`, `eventType`, or `event_type`?
   - Data structure: `{type: "conversation_updated", data: {conversation: [...]}}`?
   - Field naming: `snake_case` or `camelCase`?

3. **Event Types**
   - Does backend send `conversation_updated` when message is sent/received?
   - Does backend send `receive_message` for new messages?
   - Are these sent immediately or with delay?

4. **Connection Behavior**
   - Does backend send any welcome/connection confirmation message?
   - Does backend require any initial handshake message?

## Quick Fix: Test with Raw WebSocket

You can test the backend directly using a WebSocket client:

```javascript
// Test in browser console or Postman WebSocket
const ws = new WebSocket('ws://192.168.75.96:3000/ws', {
  headers: {
    'Authorization': 'Bearer YOUR_TOKEN_HERE'
  }
});

ws.onopen = () => {
  console.log('Connected');
};

ws.onmessage = (event) => {
  console.log('Received:', JSON.parse(event.data));
};

ws.onerror = (error) => {
  console.error('Error:', error);
};
```

This will help verify:
- Connection works
- Message format from backend
- Event types being sent

## Summary

The code is now properly set up with:
- ✅ Better connection handling
- ✅ Comprehensive logging
- ✅ Multiple data structure support
- ✅ Proper error handling

**Next Steps**:
1. Run the app and check console logs
2. Send a message from another device
3. Share the console logs with backend team
4. Verify backend message format matches expected structure
