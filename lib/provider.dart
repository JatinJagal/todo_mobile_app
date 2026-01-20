import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/providers/create_task_cubit/create_task_cubit.dart';
import 'package:todo_app/providers/login_cubit/login_cubit.dart';
import 'package:todo_app/providers/register_cubit/register_cubit.dart';
import 'package:todo_app/providers/task_list_cubit/task_list_cubit.dart';
import 'package:todo_app/providers/upcoming_task_cubit/upcoming_task_cubit.dart';
import 'package:todo_app/providers/user_profile_cubit/user_profile_cubit.dart';
import 'package:todo_app/providers/chat_request_action_cubit/chat_request_action_cubit.dart';
import 'package:todo_app/providers/chat_requests_cubit/chat_requests_cubit.dart';
import 'package:todo_app/providers/message_cubit/message_cubit.dart';
import 'package:todo_app/providers/send_chat_request_cubit/send_chat_request_cubit.dart';
import 'package:todo_app/providers/users_list_cubit/users_list_cubit.dart';
import 'package:todo_app/repository/auth_repository.dart';
import 'package:todo_app/repository/home_repository.dart';
import 'package:todo_app/repository/users_activity_repository.dart';

AuthRepository authRepository = AuthRepository();
HomeRepository homeRepository = HomeRepository();
UsersActivityRepository usersActivityRepository = UsersActivityRepository();

final List<BlocProvider> providers = [
  BlocProvider<RegisterCubit>(
    create: (context) => RegisterCubit(authRepository),
  ),
  BlocProvider<LoginCubit>(create: (context) => LoginCubit(authRepository)),
  BlocProvider<UserProfileCubit>(
    create: (context) => UserProfileCubit(authRepository),
  ),
  BlocProvider<TaskListCubit>(
    create: (context) => TaskListCubit(homeRepository),
  ),
  BlocProvider<CreateTaskCubit>(
    create: (context) => CreateTaskCubit(homeRepository),
  ),
  BlocProvider<UpcomingTaskCubit>(
    create: (context) => UpcomingTaskCubit(homeRepository),
  ),
  BlocProvider<UsersListCubit>(
    create: (context) => UsersListCubit(usersActivityRepository),
  ),
  BlocProvider<SendChatRequestCubit>(
    create: (context) => SendChatRequestCubit(usersActivityRepository),
  ),
  BlocProvider<ChatRequestsCubit>(
    create: (context) => ChatRequestsCubit(usersActivityRepository),
  ),
  BlocProvider<ChatRequestActionCubit>(
    create: (context) => ChatRequestActionCubit(usersActivityRepository),
  ),
  BlocProvider<MessageCubit>(
    create: (context) => MessageCubit(usersActivityRepository),
  ),
  BlocProvider<ConversationCubit>(
    create: (context) => ConversationCubit(usersActivityRepository),
  ),
  BlocProvider<MarkReadCubit>(
    create: (context) => MarkReadCubit(usersActivityRepository),
  ),
];
