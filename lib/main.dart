import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_template/core/cubit/form_cubit.dart';
import 'package:form_template/core/repo/section_repo.dart';
import 'package:form_template/core/service/section_service.dart';
import 'package:form_template/home/view.dart';
import 'package:form_template/models/pet_owner_model.dart';

//core

void main() {
  FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  runApp(const MediAdminForm());
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
