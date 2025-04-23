import 'dart:io';
import 'package:university_app/features/universities/domain/entities/university.dart';

class UniversityDetail {
  final University university;
  final File? image;
  final int? studentCount;

  UniversityDetail({required this.university, this.image, this.studentCount});

  UniversityDetail copyWith({
    University? university,
    File? image,
    int? studentCount,
  }) {
    return UniversityDetail(
      university: university ?? this.university,
      image: image ?? this.image,
      studentCount: studentCount ?? this.studentCount,
    );
  }
}
