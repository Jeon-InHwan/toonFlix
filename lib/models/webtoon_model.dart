class WebtoonModel {
  final String title, thumb, id;
  final bool favorite;
  WebtoonModel.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        thumb = json['thumb'],
        id = json['id'],
        favorite = false;
}
