import 'package:flutter/material.dart';
import 'package:songs_app/l10n/app_localizations.dart';
import 'package:songs_app/models/category.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.setLocale});

  final Function setLocale;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  _HomePageState();

  List<CategoryModel> categories = [];

  final controller = TextEditingController();

  String text = '';

  void _getCategories() {
    categories = CategoryModel.getCategories();
  }

  @override
  void initState() {
    controller.addListener(_onTextChange);
    super.initState();
  }

  AppBar _appbar(BuildContext context) {
    return AppBar(
      title: Text('Songs app'),
      elevation: 0,
      centerTitle: true,
      leading: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Color(0xfff7f8f8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
      ),
      actions: [
        Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xfff7f8f8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: GestureDetector(
            onTap: () {},
            child: Icon(
              Icons.keyboard_control,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
        ),
      ],
    );
  }

  Column categoryColumn(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 40),
        SizedBox(
          height: 40,
          child: Padding(
            padding: EdgeInsetsGeometry.only(left: 20),
            child: Text(
              AppLocalizations.of(context)!.helloWorld,
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.left,
            ),
          ),
        ),
        SizedBox(height: 40),
        Container(
          height: 150,
          color: Colors.white,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            padding: EdgeInsets.only(left: 20, right: 20),
            separatorBuilder: (context, index) {
              return SizedBox(width: 5);
            },
            itemBuilder: (context, index) {
              return Container(
                width: 100,
                decoration: BoxDecoration(
                  color: categories[index].boxColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(categories[index].name),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget changeLanguage(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsetsGeometry.all(30),
        child: GestureDetector(
          onTap: () {
            final currentLocale = Localizations.localeOf(context).languageCode;
            if (currentLocale == 'en') {
              widget.setLocale(Locale('ru'));
            } else {
              widget.setLocale(Locale('en'));
            }
          },
          child: SizedBox(
            height: 100,
            width: 100,
            child: Icon(Icons.language, size: 100),
          ),
        ),
      ),
    );
  }

  Widget textCtrl(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(10.0),
      child: Center(
        child: Column(
          children: [
            TextField(controller: controller),
            Text(text),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _getCategories();

    return Scaffold(
      appBar: _appbar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textCtrl(context),
          // searchField(context),
          // categoryColumn(context),

          // changeLanguage(context),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onTextChange() {
    setState(() {
      text = controller.text.toLowerCase();
    });
  }
}

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 40, left: 20, right: 20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.30),
            blurRadius: 40,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          // fillColor: Theme.of(context).cardColor,
          contentPadding: EdgeInsets.all(15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          hintText: AppLocalizations.of(context)!.search,
          hintStyle: Theme.of(context).textTheme.labelMedium,
          prefixIcon: Icon(Icons.search),
          suffixIcon: SizedBox(
            width: 50,
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  VerticalDivider(
                    color: Theme.of(context).colorScheme.secondary,
                    thickness: 1,
                    indent: 10,
                    endIndent: 10,
                  ),
                  Icon(Icons.filter_list_outlined),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
