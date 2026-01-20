class Endpoints {
  static const String register = 'auth/register';
  static const String login = 'auth/login';
  static const String getProfile = 'auth/getProfile';
  static const String createTask = 'todo/create_task';
  static const String getTasks = 'todo/get_tasks';
  static const String getUpcomingTasks = 'todo/get_upcoming_tasks';
  static const String getAllUsersList = 'auth/users';

  //Chat
  static const String sentChatRequest = 'chat/send-request';
  static const String getChatRequest = 'chat/requests';
  static const String acceptChatRequest = 'chat/accept-request';
  static const String rejectChatRequest = 'chat/reject-request';
  static const String removeChatRequest = 'chat/remove-request';
  static const String sendMessage = 'chat/send-message';
  static const String getConversation = 'chat/conversation';
  static const String markMessageRead = 'chat/mark-read';
}
