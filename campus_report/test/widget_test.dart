import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_report/models/user_model.dart';
import 'package:campus_report/models/incident_model.dart';
import 'package:campus_report/utils/validators.dart';
import 'package:campus_report/widgets/status_badge.dart';
import 'package:campus_report/widgets/status_timeline.dart';

void main() {
  group('ALU Email & Form Validation Tests', () {
    test('Accepts valid @alustudent.com and @alueducation.com emails', () {
      expect(Validators.validateAluEmail('e.hategekimana@alustudent.com'), isNull);
      expect(Validators.validateAluEmail('staff@alueducation.com'), isNull);
    });

    test('Rejects non-ALU email domains and empty inputs', () {
      expect(Validators.validateAluEmail('user@gmail.com'), isNotNull);
      expect(Validators.validateAluEmail(''), isNotNull);
    });

    test('Validates password minimum length and required fields', () {
      expect(Validators.validatePassword('12345'), isNotNull);
      expect(Validators.validatePassword('securePass123'), isNull);
      expect(Validators.validateRequired('', 'Title'), isNotNull);
      expect(Validators.validateRequired('Water leak', 'Title'), isNull);
    });
  });

  group('Model & Role-Based Access Control Tests', () {
    test('UserModel.isStaff returns true only when role is staff', () {
      final student = UserModel(
        uid: 'u1',
        name: 'Student User',
        email: 'student@alustudent.com',
        role: 'student',
        createdAt: DateTime(2026, 10, 15),
      );
      final staff = student.copyWith(role: 'staff');

      expect(student.isStaff, isFalse);
      expect(staff.isStaff, isTrue);
    });

    test('IncidentModel masks reporter name when isAnonymous is true', () {
      final incident = IncidentModel(
        id: 'inc1',
        title: 'Broken security light',
        description: 'Corridor light is out near Block B.',
        category: 'Safety',
        location: 'Block B — Room 204',
        reporterId: 'u1',
        reporterName: 'Amina Hassan',
        isAnonymous: true,
        createdAt: DateTime(2026, 10, 15),
      );

      expect(incident.displayReporterName, equals('Anonymous Student'));
    });
  });

  group('Reusable Widget UI Tests', () {
    testWidgets('StatusBadge renders correct status label', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: 'In Progress'),
          ),
        ),
      );

      expect(find.text('In Progress'), findsOneWidget);
    });

    testWidgets('StatusTimeline displays all 3 resolution stages', (WidgetTester tester) async {
      final incident = IncidentModel(
        id: 'inc2',
        title: 'Water shortage',
        description: 'No water in residence.',
        category: 'Water',
        location: 'Student Residence',
        status: 'In Progress',
        reporterId: 'u1',
        reporterName: 'Amina Hassan',
        createdAt: DateTime(2026, 10, 15, 10, 24),
        inProgressAt: DateTime(2026, 10, 15, 14, 30),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusTimeline(incident: incident),
          ),
        ),
      );

      expect(find.text('Status Timeline'), findsOneWidget);
      expect(find.text('Submitted'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);
      expect(find.text('Resolved'), findsOneWidget);
    });
  });
}