// import '../../domain/entities/login_response_entity.dart';
// import '../models/login_response_dm.dart';
//
// extension ParentLoginDmMapper on ParentLoginDm {
//   ParentLoginEntity toEntity() {
//     return ParentLoginEntity(
//       id: id,
//       name: name,
//       email: email,
//       phone: phone,
//       role: role,
//       status: status,
//       createdAt: createdAt,
//       students: students?.map((s) => s.toEntity()).toList(),
//     );
//   }
// }
//
// extension StudentsLoginDmMapper on StudentsDm {
//   StudentsLoginEntity toEntity() {
//     return StudentsLoginEntity(
//       id: id,
//       nickName: nickName,
//       imageLink: imageLink,
//     );
//   }
// }

// extension ParentLoginEntityMapper on ParentLoginEntity {
//   ParentLoginDm toDm() {
//     return ParentLoginDm(
//       id: id,
//       name: name,
//       email: email,
//       phone: phone,
//       role: role,
//       status: status,
//       createdAt: createdAt,
//       students: students?.map((s) => s.toDm()).toList(),
//     );
//   }
// }
//
// extension StudentsLoginEntityMapper on StudentsLoginEntity {
//   StudentsDm toDm() {
//     return StudentsDm(
//       id: id,
//       nickName: nickName,
//       imageLink: imageLink,
//     );
//   }
// }
