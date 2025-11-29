import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_template/core/cubit/form_cubit.dart';
import 'package:form_template/core/repo/section_repo.dart';
import 'package:form_template/core/service/section_service.dart';
import 'package:form_template/firebase_options.dart';
import 'package:form_template/home/view.dart';
import 'package:form_template/models/pet_owner_model.dart';

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    try {
      // Configure Firestore with emulator and persistence
      FirebaseFirestore.instance.settings = const Settings(
        host: 'localhost:8080',
        sslEnabled: false,
        persistenceEnabled: true,
      );

      // Configure Functions emulator
      FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5002);

      debugPrint('Firebase emulators initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Firebase emulators: $e');
      rethrow;
    }
  } else {
    // Production settings
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeFirebase();
    runApp(const MediAdminForm());
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
    // You might want to show an error UI here
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Failed to initialize Firebase. Please try again.'),
          ),
        ),
      ),
    );
  }
}

class MediAdminForm extends StatelessWidget {
  const MediAdminForm({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SectionRepo<PetOwnerModel>>(
          create: (_) => SectionRepo<PetOwnerModel>(
            SectionService<PetOwnerModel>(
              'petOwners',
              (data) => PetOwnerModel.fromJson(data),
            ),
          ),
          lazy: false,
        ),
      ],
      child: Builder(
        builder: (context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => FormCubit<PetOwnerModel>(
                  repo: RepositoryProvider.of<SectionRepo<PetOwnerModel>>(
                    context,
                  ),
                ),
              ),
            ],
            child: MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              ),
              home: HomeView(),
            ),
          );
        },
      ),
    );
  }
}
