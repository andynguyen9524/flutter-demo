import 'package:flutter/material.dart';

class HomeParam {
  final String? username;
  final Function(String)? onTapItem;

  HomeParam({this.username, this.onTapItem});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.param});

  final HomeParam param;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final arrayInt =  [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  final _scrollController = ScrollController();
  var isLoading = false;
  @override
  void initState() {
    // You can add any initialization logic here if needed
    super.initState();
    _scrollController.addListener(()async {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent && !isLoading) {
        // Load more data or perform an action when scrolled to the bottom
        isLoading = true;
        print('Reached the bottom of the list');
        final temp = await fetchData();
        isLoading = false; // Allow further loading
        setState(() {
          arrayInt.addAll(temp);
        });
      }
    });
  }

  Future<List<int>> fetchData() async {
    await Future.delayed(const Duration(seconds: 2));
    return List.generate(10, (index) => index + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: Text('welcome ${widget.param.username??''}'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        
      ),
      
      body: ListView.builder(
        controller: _scrollController,
        itemCount: arrayInt.length + 1,
        itemBuilder: (context, index) {
          if (index == arrayInt.length) {
            return SizedBox(
              width: 100,
              height: 100,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            return InkWell(
              onTap: (){
                if(widget.param.onTapItem == null)
                  {return;}
                
                widget.param.onTapItem!( 'Item Title ${index+1}');
                Navigator.pop(context);
              },
              child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Large image
                  SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: Image.network(
                      'https://picsum.photos/seed/${index+1}/600/200',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Item Title ${index+1}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This is a description for item $index. It contains some information about the image above.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
                        ),
            );
          }
          
        },
        
      ),
    );
  }
}
