import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';


import 'package:sqflite/sqflite.dart';
import 'package:to_do_cuibt/cubit/states.dart';

import '../layout/archived.dart';
import '../layout/done_screen.dart';
import '../layout/new_screen.dart';



class MainScreenCubit extends Cubit<TodoStates> {
  MainScreenCubit() : super(InitialState());

  // easy access from UI
  static MainScreenCubit of(BuildContext ctx) =>
      BlocProvider.of<MainScreenCubit>(ctx);

  // ── bottom‑nav index ─────────────────────────────────────────
  int currentIndex = 0;
  void changeBottomIndex(int idx) {
    currentIndex = idx;
    emit(ChangeBottomIndexState());
  }

  // ── three separate lists for UI ─────────────────────────────

  List<Map<String, dynamic>> allTasks      = [];
  List<Map<String, dynamic>> doneTasks     = [];
  List<Map<String, dynamic>> archivedTasks = [];

  // ── tab screens (declared elsewhere) ───────────────────────
  final screens = const [
    NewScreen(),
    DoneScreen(),
    ArchivedScreen(),
  ];

  // ── SQLite instance (non‑null after createDatabase) ─────────
  late Database database;

  // ── 1. create / open DB ─────────────────────────────────────
  Future<void> createDatabase() async {
    database = await openDatabase(
      'todo.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks(
            id     INTEGER PRIMARY KEY AUTOINCREMENT,
            title  TEXT,
            date   TEXT,
            time   TEXT,
            status TEXT
          )
        ''');
      },
    );

    emit(CreateDatabaseState());
    await _refreshLists();      // populate lists on launch
  }

  // ── 2. insert new row ───────────────────────────────────────
  Future<void> insertTask({
    required String title,
    required String date,
    required String time,
  }) async {
    await database.transaction((txn) async {
      await txn.rawInsert(
        'INSERT INTO tasks(title,date,time,status) VALUES(?,?,?,?)',
        [title, date, time, 'new'],
      );
    });

    emit(InsertDatabaseState());
    await _refreshLists();
  }

  // ── 3. update row (partial) ─────────────────────────────────
  Future<void> updateTask({
    required int id,
    String? title,
    String? date,
    String? time,
    String? status, // 'new' / 'done' / 'archived'
  }) async {
    final Map<String, Object?> values = {};
    if (title  != null) values['title']  = title;
    if (date   != null) values['date']   = date;
    if (time   != null) values['time']   = time;
    if (status != null) values['status'] = status;

    if (values.isEmpty) return;   // nothing to change

    await database.update(
      'tasks',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );

    emit(UpdateDatabaseState());
    await _refreshLists();
  }

  /// Convenience wrapper: just change status
  Future<void> changeTaskStatus({
    required int id,
    required String newStatus, // 'done', 'archived', 'new'
  }) =>
      updateTask(id: id, status: newStatus);

  // ── 4. delete row ───────────────────────────────────────────
  Future<void> deleteTask(int id) async {
    await database.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    emit(DeleteDatabaseState());
    await _refreshLists();
  }

  // ── private: read table -> fill lists -> emit ───────────────

  Future<void> _refreshLists() async {
    final rows = await database.rawQuery(
      'SELECT * FROM tasks ORDER BY id DESC',
    );

    allTasks      = rows;                              // every task
    doneTasks     = rows.where((r) => r['status'] == 'done').toList();
    archivedTasks = rows.where((r) => r['status'] == 'archived').toList();

    emit(GetDatabaseSuccessState());
  }
}
