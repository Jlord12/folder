import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ObjectProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
         
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

@immutable
class BaseObject {
final String id;
final String lastUpdated;
 BaseObject() : id = Uuid().v4(), lastUpdated = DateTime.now().toIso8601String();

 @override
 bool operator == (covariant BaseObject other) => id == other.id;

 @override

 int get hashCode => id.hashCode;
}

@immutable
class  ExpensiveObject extends BaseObject {}

@immutable

class  CheapObject extends BaseObject {}

class ObjectProvider extends ChangeNotifier{
  late String id;
  late CheapObject _cheapObject;
  late StreamSubscription _cheapStreamSubscription;
  late ExpensiveObject _expensiveObject;
  late StreamSubscription _expensiveStreamSubscription;

  CheapObject get cheapObject => _cheapObject;

  ExpensiveObject get expensiveObject => _expensiveObject;

  ObjectProvider() : id = const Uuid().v4(), _cheapObject = CheapObject(), _expensiveObject= ExpensiveObject(){
    start();
  }


  @override
  void notifyListeners() {
    id =const  Uuid().v4();
    super.notifyListeners();
  }

  void start(){
    _cheapStreamSubscription = Stream.periodic(const Duration(seconds: 1)).listen((event) { 
      _cheapObject = CheapObject();
      notifyListeners();
    });

    _expensiveStreamSubscription = Stream.periodic(const Duration(seconds: 10)).listen((event) { 
      _expensiveObject = ExpensiveObject();
      notifyListeners();
    });
  }

  void stop(){
    _cheapStreamSubscription.cancel();
    _expensiveStreamSubscription.cancel();
  }


}


class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text( 'HomePage'),
      ),
      body:  Column(
        children: [
          const Row(
            children: [
              Expanded(child: CheapObjectWidget()),
              Expanded(child: ExpensiveWidget()),
            ],
          ),
        const Row(
          children: [
            Expanded(child:   OjectProviderWidget()),
          ],
        ),
        SizedBox(height: 20,),
               Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellowAccent
          ),
          onPressed: (){
            context.read<ObjectProvider>().start();
          },
         child: const Text('Start',style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),),
         ),
         
         
        ElevatedButton(
           style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellowAccent
          ),
          onPressed: (){
            context.read<ObjectProvider>().stop();
          },
         child: const Text('Stop',style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),),
         ),
                ],
               ),
        ],
      ),
    );
  }
}

class CheapObjectWidget extends StatelessWidget {
  
  const CheapObjectWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cheapObject = context.select<ObjectProvider,CheapObject>(
      (Provider2) => Provider2.cheapObject,
    );
    return Container(
      height: 100,
      color: Colors.yellow,
      child:  Column(
        children: [
          const Text('Cheap Widget',style:  TextStyle(fontSize: 19,color: Colors.white,fontWeight: FontWeight.bold),),
          const Text('Last Updated',style:  TextStyle(fontSize: 19,color: Colors.white,fontWeight: FontWeight.bold),),
          Expanded(child: Text(cheapObject.lastUpdated,style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)),
        ],
      ),
    );
  }
}


class ExpensiveWidget extends StatelessWidget {
  const ExpensiveWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final expensiveObject = context.select<ObjectProvider, ExpensiveObject>(
      (Provider) =>Provider.expensiveObject);
    return  Container(
      height: 100,
      color: Colors.blue,
      child:  Column(
        children: [
           const Text('Expensive Widget',style:  TextStyle(fontSize: 19,color: Colors.white,fontWeight: FontWeight.bold),),
           const Text('Last Upaated',style:  TextStyle(fontSize: 19,color: Colors.white,fontWeight: FontWeight.bold),),
            Expanded(child: Text(expensiveObject.lastUpdated,style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)),
        ],
      ),
    );
  }
}

class OjectProviderWidget extends StatelessWidget {
  const OjectProviderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ObjectProvider>();
   return  Container(
      height: 100,
      color: Colors.purple,
      child:  Column(
        children: [
           const Text('Object Provider Widget',style:  TextStyle(fontSize: 19,color: Colors.white,fontWeight: FontWeight.bold),),
           const Text('ID',style:  TextStyle(fontSize: 19,color: Colors.white,fontWeight: FontWeight.bold),),
            Text(provider.id,style: const TextStyle(fontSize: 19,color: Colors.white,fontWeight: FontWeight.bold),),
        ],
      ),
    );
  }
}

