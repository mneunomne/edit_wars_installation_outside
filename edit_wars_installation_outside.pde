import java.util.*;
import java.text.SimpleDateFormat;  
import java.time.*;
import java.time.temporal.ChronoUnit;
import java.time.format.DateTimeFormatter;

PShader myShader;
PGraphics pg;
boolean loadedImage = false;

PImage currentImage;

Table table;
int num_rows;

int img_width = 500;
int img_height = 500;

ArrayList <String> dates = new ArrayList <String> ();

// array list of pimages
ArrayList <String> headline_images_path = new ArrayList <String> ();
ArrayList <String> headline_strings = new ArrayList <String> ();

// miliseconds per narrative
int miliseconds_per_narrative = 15 * 60 * 1000;

// load space mono font
PFont font; 

int index = 0;

void setup() {
  size(1200, 900, P3D);
  background(0);
  
  pg = createGraphics(width, height, P3D);
  
  dates = getDatesBetween("2022-01-01", "2022-07-31");
  
  // load font
  font = createFont("fonts/roboto-mono-v22-latin_cyrillic-regular.ttf", 48);
  textFont(font);
  
  myShader = loadShader("shader/glitch.glsl");
  myShader.set("iResolution", float(1200), float(900));
  
  headline_images_path = new ArrayList <String> ();
  headline_strings = new ArrayList <String> ();
  
  loadData();
  
  // get nuber of rows
  num_rows = table.getRowCount();
}

// get arraylist filtered data by date
ArrayList <TableRow> getFilteredDataByDate(String date) {
  ArrayList <TableRow> filtered_data = new ArrayList <TableRow> ();
  for (int i = 0; i < table.getRowCount(); i++) {
    TableRow row = table.getRow(i);
    String row_date = row.getString("date");
    if (row_date.equals(date)) {
      filtered_data.add(row);
    }
  }
  return filtered_data;
}

void loadData() {
  // load csv data file
  table = loadTable("data/full_data.tsv", "header");
}



void draw() {
  if (index >= num_rows) {
    index = 0;
  }
  
  // background(0);
  
  // get current miliseconds
  long current_miliseconds = millis() % miliseconds_per_narrative;
  // miliseconds per date
  long miliseconds_per_date = miliseconds_per_narrative / dates.size();
  // get current date
  int current_date_index = (int)(current_miliseconds / miliseconds_per_date);
  // get current date
  String current_date = dates.get(current_date_index);
  
  // get filtered data by date
  ArrayList <TableRow> filtered_data = getFilteredDataByDate(current_date);
  // get random row from filtered data
  int millis_per_filtered_data = (int)(miliseconds_per_date / filtered_data.size());
  int current_index = (int)(current_miliseconds % miliseconds_per_date / millis_per_filtered_data);
  println("current_index", current_index, filtered_data.size());
  
  if (current_index >= filtered_data.size()) {
    current_index = 0;
  }
  if (filtered_data.size() == 0) {
    return;
  }
  
  TableRow row = filtered_data.get(current_index);
  boolean has_image = row.getInt("has_image") == 1;
  // get extension of file string and check if it is an image
  
  myShader.set("iTime", millis() / 1.);
  
  if (has_image) {
    String path = "data/headline_images/" + row.getString("image_path");
    String extension = path.substring(path.lastIndexOf(".") + 1).toLowerCase();
    boolean is_valid_extension = extension.equals("jpg") || extension.equals("png") || extension.equals("gif") || extension.equals("jpeg") || extension.equals("tiff");
    if (is_valid_extension) {
      // println(path);
      PImage img = loadImage(path);
      if (img.width > 0 && img.height > 0) {
        if (img.width > img.height) {
          img.resize(0, img_height);
        } else {
          img.resize(img_width, 0);
        }
        currentImage = img;
        loadedImage = true;
        // filter
        //tint(255, 0, 0, 20);
        
      }
    }
  }
  pg.beginDraw();
  if (loadedImage) {
    pg.image(currentImage, 0, 0);
  }
  pg.tint(200 + random(50), 0, random(50), 19);  // Tint blue
  pg.shader(myShader);
  pg.endDraw();
  
  image(pg, 0, 0);
  // text size
  textSize(28);
  fill(0, 0, 0, 100);
  rect(0, img_height + 20, width, height);
  fill(255);
  text(row.getString("text"), 20, img_height + 20, 500, height);
  
  text(current_date, 20, 20, 500, height);
  text(String.valueOf(current_miliseconds), 20, 50, 500, height);
  index++;
}


// get days between two dates
int daysBetween(Date d1, Date d2) {
  return(int)((d2.getTime() - d1.getTime()) / (1000 * 60 * 60 * 24));
}

// get list of date strings between two dates
ArrayList <String> getDatesBetween(String d1, String d2) {
  DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern("yyyy-MM-dd");
  ArrayList <String> dates = new ArrayList <String> ();
  println("d1", d1, "d2", d2);
  LocalDate date1, date2;
  try {
    date1 = LocalDate.parse(d1);
    date2 = LocalDate.parse(d2);
    long days = ChronoUnit.DAYS.between(date1, date2);
    LocalDate date = date1.plusDays(days);
    println("days", days);
    for (int i = 0; i < days + 1; i++) {
      LocalDate newDate = date1.plusDays(i);
      String formattedString = newDate.format(dateFormat);
      formattedString = formattedString.replace("-", ".");
      dates.add(formattedString);
      println(i, formattedString);
    }
  } catch(Exception e) {
    println("error parsing dates");
  }
  return dates;
}