import 'dart:convert';
import 'package:flutter/material.dart';
import 'main.dart';

// Memo 데이터의 형식을 정해줍니다. 추후 isPinned, updatedAt 등의 정보도 저장할 수 있습니다.
// 이 메모클래스는 컨텐트(글)과 핀정보를 담은 클래스이다
class Memo {
  Memo({required this.content, this.isPinned = false, this.updateTime,});

  String content;
  bool isPinned;
  DateTime? updateTime;

// map을 반환하는 toJson이라는 메소드인데, Memo.toJson 하면 기존 형식을 Json형식의 Map값으로 반환해
  Map toJson() {
    return {
      'content': content,
      'isPinned': isPinned,
      'updateTime' : updateTime?.toIso8601String(),
    };
  }

  factory Memo.fromJson(json) {
    return Memo(
      content: json['content'],
      isPinned: json['isPinned'] ?? false,
      updateTime: json['updateTime'] == null ? null : DateTime.parse(json['updateTime']),
    );
  }
}

// Memo 데이터는 모두 여기서 관리
class MemoService extends ChangeNotifier {
  MemoService() {
    loadMemoList();
  }

  List<Memo> memoList = [];

  createMemo({
    required String content,
  }) {
    Memo memo = Memo(
      content: content,
      updateTime: DateTime.now()
    );
    memoList.add(memo);
    notifyListeners();

    saveMemoList();
    //이게 상태변화를 리스너(컨슈머)에게 알리는 코드
  }

  updateMemo({required int index, required String content}) {
    Memo memo = memoList[index];
    memo.content = content;
    memo.updateTime = DateTime.now();
    notifyListeners();
    saveMemoList();
  }

  updatePinMemo({required int index}) {
    Memo pinMemo = memoList[index];
    pinMemo.isPinned = !pinMemo.isPinned;

    memoList = [
      ...memoList.where((element) => element.isPinned),
      ...memoList.where((element) => !element.isPinned),
    ];

    notifyListeners();
    saveMemoList();
  }

  deleteMemo({required int index}) {
    memoList.removeAt(index);
    notifyListeners();
    saveMemoList();
  }

  saveMemoList() {
    List memoJsonList = memoList.map((memo) => memo.toJson()).toList();
    // [{"content": "1"}, {"content": "2"}]

    String jsonString = jsonEncode(memoJsonList);
    // '[{"content": "1"}, {"content": "2"}]'

    prefs.setString('memoList', jsonString);
  }

  loadMemoList() {
    String? jsonString = prefs.getString('memoList');
    // '[{"content": "1"}, {"content": "2"}]'

    if (jsonString == null) return; // null 이면 로드하지 않음

    List memoJsonList = jsonDecode(jsonString);
    // [{"content": "1"}, {"content": "2"}]

    memoList = memoJsonList.map((json) => Memo.fromJson(json)).toList();
  }
}
