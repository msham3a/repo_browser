import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var username_controller = TextEditingController();
  List list_of_repos=[''];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List GITHUB Username repos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            TextFormField(
              controller: username_controller,
              decoration: const InputDecoration(
                hintText: 'Username',
                hintStyle: TextStyle(fontSize: 25),
                border: UnderlineInputBorder(),
                icon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 15.0,),
            Container(
              width: 250.0,
              child: TextButton(
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: const BorderSide(color: Colors.blue)
                        )
                    )
                ),
                onPressed: () async {
                  list_of_repos = await getApiData(username_controller.text.trim());
                  setState(() {
                    list_of_repos=list_of_repos;
                    username_controller=username_controller;
                  });
                  //print(list_of_repos);
                },
                child: const Text('List Repositories',style: TextStyle(fontSize: 25,),),
              ),
            ),
            const SizedBox(height: 15.0,),
            buildReposList(list_of_repos),
          ],
        ),
      ),
    );
  }
}

Widget buildReposList(List list_of_repos) => Expanded(
  child:   ListView(
      children:[ Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              separatorBuilder: (context, index) {
                return const SizedBox(
                  height: 15.0,
                );
              },
              itemBuilder: (context, index) {
                return buildRepoItem(list_of_repos[index]);
              },
              itemCount: list_of_repos.length,
              scrollDirection: Axis.vertical,
            ),
          ]),
      ]
  ),
);


Widget buildRepoItem(String url) => Row(
  children: [  Expanded(
    child: TextButton(child: Text(url,maxLines: 2,textAlign: TextAlign.center,style: const TextStyle(fontSize: 20,),),
      onPressed: () async {
        var urllaunchable =await canLaunchUrl(Uri.parse(url));
        if(urllaunchable){
          await launchUrl(Uri.parse(url),mode: LaunchMode.externalApplication);
        }else{
          print("URL can't be launched.");
        }
      },
    ),
  ),
  ],
);

Future<List> getApiData(String username) async {
  var url = Uri.https('api.github.com', 'users/${username}/repos', {'q': '{dart}'});
  final response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "Access-Control_Allow_Origin": "*"
      });

  //print(response.statusCode);
  List<dynamic> repos = jsonDecode(response.body);
  //print(repos.length);
  List repos_html_urls = [];
  for (var repo in repos){
    repos_html_urls.add(repo['html_url']);
  }
  //print(repos_html_urls);
  return repos_html_urls;
}