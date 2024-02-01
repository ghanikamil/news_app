import 'dart:convert';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/pages/news.dart';

class ListNews extends StatefulWidget {
  const ListNews({super.key});

  @override
  State<ListNews> createState() => _ListNewsState();
}

class _ListNewsState extends State<ListNews> {
  final words = nouns.take(10).toList();
  Future <List<News>> _getNews() async {
    var response = await http.get(Uri.parse(
        'https://newsapi.org/v2/everything?q=keyword&apiKey=4b397c0b925c48649a61b00c6ab69622'));
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      List<dynamic> articles = jsonData['articles'];
      List<News> newsList = articles.map(
              (article) {
            return News(
                title: article['title'] ?? 'default title',
                description: article['description'] ?? 'default description',
                imageURL: article['urlToImage'] ?? 'default image',
                url: article['url'] ?? 'default url'
            );
          }
      ).toList();
      return newsList;
    }
    else {
      throw Exception('Failed to load news, status code: ${response.statusCode}');
    }
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('NEWS TODAY'),
            bottom: TabBar(
              tabs:<Widget> [
                Tab(
                  icon: Icon(Icons.newspaper),
                  child: Text('News'),
                ),
                Tab(
                  icon: Icon(Icons.favorite),
                  child: Text('Favorite'),
                )
              ],
            ),
          ),
          body: TabBarView(
            children:  [
              FutureBuilder<List<News>>(
                future: _getNews(),
                builder: (context, snapshot){
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return Center(child: CircularProgressIndicator());
                  }
                  else{
                    return ValueListenableBuilder(
                      valueListenable: Hive.box('favorites_news').listenable(),
                      builder: (context, box, child){
                        return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index){
                              var article = snapshot.data![index];
                              final word = words[index];
                              final isFavorite = box.get(index) != null;
                              return Card(
                                elevation: 3,
                                margin: EdgeInsets.all(5),
                                child: ListTile(
                                    leading: Image.network("${article.imageURL}"),
                                    title: Text(article.title),
                                    subtitle: Text(article.description),
                                    trailing: IconButton(
                                      onPressed: () async{
                                        ScaffoldMessenger.of(context).clearSnackBars();
                                        if(isFavorite){
                                          await box.delete(index);
                                          const snackBar = SnackBar(
                                            content: Text('Delete Succesfully'),
                                            backgroundColor: Colors.red,
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                        }else{
                                          await box.put(index, true);
                                          const snackBar = SnackBar(
                                            content: Text('Added Succesfully'),
                                            backgroundColor: Colors.blue,
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                        }


                                      },
                                      icon: Icon(
                                        isFavorite ? Icons.favorite : Icons.favorite_border,
                                        color: Colors.red,),
                                    )
                                ),
                              );
                            }
                        );
                      },
                    );
                  }

                },

              ),

              Container(
                child: Text('HALAMAN 2')
              ),

            ],
          )
        )
    );
  }
}
