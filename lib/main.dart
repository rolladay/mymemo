//git test

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'memo_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MemoService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

// 홈 페이지
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MemoService>(builder: (context, memoService, child) {
      List<Memo> memoList = memoService.memoList;

      return Scaffold(
        appBar: AppBar(
          title: Text("mymemo"),
        ),
        body: memoList.isEmpty
            ? Center(child: Text("메모를 작성해주세요"))
            : ListView.builder(
                itemCount: memoList.length, // memoList 개수 만큼 보여주기
                itemBuilder: (context, index) {
                  Memo memo = memoList[index]; // index에 해당하는 memo 가져오기
                  return ListTile(
                    // 메모 고정 아이콘
                    leading: IconButton(
                      icon: Icon(
                        memo.isPinned
                            ? CupertinoIcons.pin_fill
                            : CupertinoIcons.pin,
                      ),
                      onPressed: () {
                        memoService.updatePinMemo(index: index);
                      },
                    ),
                    // 메모 내용 (최대 3줄까지만 보여주도록)
                    title: Text(
                      memo.content,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      memo.updateTime == null ? '' : memo.updateTime.toString().substring(0,16),
                    ),
                    onTap: ()   async{
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailPage(
                            index: index,
                          ),
                        ),
                      );
                      if(memo.content.isEmpty){
                        memoService.deleteMemo(index: index);
                      }
                    },
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            memoService.createMemo(content: '');
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailPage(
                  index: memoService.memoList.length - 1,
                ),
              ),
            );
            if(memoList.last.content.isEmpty){
              memoService.deleteMemo(index: memoList.length -1);
            }

          },
        ),
      );
    });
  }
}

// 메모 생성 및 수정 페이지
class DetailPage extends StatelessWidget {
  DetailPage({super.key, required this.index});

  final int index;

  TextEditingController contentControllerR = TextEditingController();

  @override
  Widget build(BuildContext context) {
    MemoService memoService = context.read<MemoService>();
    Memo memo = memoService.memoList[index];

    contentControllerR.text = memo.content;

    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              // 삭제 버튼 클릭시
              showDeleteDialogue(context, memoService);
            },
            icon: Icon(Icons.delete),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: contentControllerR,
          decoration: InputDecoration(
            hintText: "메모를 입력하세요",
            border: InputBorder.none,
          ),
          autofocus: true,
          maxLines: null,
          expands: true,
          keyboardType: TextInputType.multiline,
          onChanged: (value) {
            memoService.updateMemo(index: index, content: value);
            // 원래는 이거였지? memoList[index] = value;
          },
        ),
      ),
    );
  }

  Future<dynamic> showDeleteDialogue(
      BuildContext context, MemoService memoService) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("정말로 삭제하시겠습니까?"),
          actions: [
            // 취소 버튼
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("취소"),
            ),
            // 확인 버튼
            TextButton(
              onPressed: () {
                memoService.deleteMemo(index: index);
                Navigator.pop(context); // 팝업 닫기
                Navigator.pop(context);
              },
              child: Text(
                "확인",
                style: TextStyle(color: Colors.pink),
              ),
            ),
          ],
        );
      },
    );
  }
}
