import 'package:mxplayer/Details/series.dart';
import 'package:mxplayer/utils/Moviees.dart';
import 'package:mxplayer/utils/games.dart';

List<Movies> movieslist() {
  List<Movies> ml = [];
  Movies m = Movies();

  //1
  m.img = "assets/charlie.jpg";
  ml.add(m);
  m = Movies();

  //2
  m.img = "assets/valimai.jpg";
  ml.add(m);
  m = Movies();

  //3
  m.img = "assets/vivegam.jpg";
  ml.add(m);
  m = Movies();

  //4
  m.img = "assets/yennai arindhal.jpg";
  ml.add(m);
  m = Movies();

  return ml;
}

List<serieslist> serieList() {
  List<serieslist> sl = [];
  serieslist s = serieslist();

  //1
  s.img = "assets/peakyblinders.jpg";
  sl.add(s);
  s = serieslist();

  //2
  s.img = "assets/money.jpg";
  sl.add(s);
  s = serieslist();

  //3
  s.img = "assets/tvd.jpg";
  sl.add(s);
  s = serieslist();

  //4
  s.img = "assets/orginals.jpeg";
  sl.add(s);
  s = serieslist();

  //5
  s.img = "assets/legacies.jpg";
  sl.add(s);
  s = serieslist();

  return sl;
}

List<games> getGames() {
  List<games> gl = [];
  games g = games();

  //1
  g.img = "assets/gta5.jpg";
  gl.add(g);
  g = games();

  //2
  g.img = "assets/asphalt.jpg";
  gl.add(g);
  g = games();

  //3
  g.img = "assets/bully.jpg";
  gl.add(g);
  g = games();

  //4
  g.img = "assets/ac.jpg";
  gl.add(g);
  g = games();

  return gl;
}

List<games> getGames2() {
  List<games> gl = [];
  games g = games();

  //1
  g.img = "assets/mario.jpg";
  gl.add(g);
  g = games();

  //2
  g.img = "assets/mini.jpg";
  gl.add(g);
  g = games();

  //3
  g.img = "assets/bully.jpg";
  gl.add(g);
  g = games();

  //4
  g.img = "assets/zombie.jpg";
  gl.add(g);
  g = games();

  return gl;
}

List<Movies> songslist() {
  List<Movies> sl = [];
  Movies m = Movies();

  //1
  m.img = "assets/param.jpg";
  sl.add(m);
  m = Movies();

  //2
  m.img = "assets/thooriga.jpg";
  sl.add(m);
  m = Movies();

  //3
  m.img = "assets/kuty.jpg";
  sl.add(m);
  m = Movies();

  //4
  m.img = "assets/enjoy.jpg";
  sl.add(m);
  m = Movies();

  return sl;
}

List<Movies> songplaylist() {
  List<Movies> sll = [];
  Movies m = Movies();

  //1
  m.img = "assets/ser2.jfif";
  sll.add(m);
  m = Movies();

  //2
  m.img = "assets/ser4.jfif";
  sll.add(m);
  m = Movies();

  //3
  m.img = "assets/ser5.jfif";
  sll.add(m);
  m = Movies();

  //4
  m.img = "assets/weekly.jfif";
  sll.add(m);
  m = Movies();

  return sll;
}
