package com.a011.statusforever;

import android.Manifest;
import android.app.AlertDialog;
import android.content.ContentResolver;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.media.MediaScannerConnection;
import android.media.ThumbnailUtils;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.StrictMode;
import android.provider.ContactsContract;
import android.provider.MediaStore;
import android.support.annotation.Nullable;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.util.Log;
import android.widget.Toast;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.lang.reflect.Method;
import java.net.URI;
import java.nio.channels.FileChannel;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    // declaring unique channelID for app
    public static final String CHANNEL_ID = "com.a011.statusforever";
    private int storagePermissionCode = 1;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        if (Build.VERSION.SDK_INT >= 24) {
            try {
                Method m = StrictMode.class.getMethod("disableDeathOnFileUriExposure");
                m.invoke(null);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        new MethodChannel(getFlutterView(), CHANNEL_ID).setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {

                // handles call to check permission status
                if (methodCall.method.equals("checkPermission")) {

                    // checking permission status and returning result
                    if (ContextCompat.checkSelfPermission(MainActivity.this, Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED && ContextCompat.checkSelfPermission(MainActivity.this, Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED && ContextCompat.checkSelfPermission(MainActivity.this, Manifest.permission.READ_CONTACTS) == PackageManager.PERMISSION_GRANTED) {
                        result.success("Granted");
                    } else {
                        result.success("Denied");
                    }

                }
                // method to get permission
                else if (methodCall.method.equals("getPermission")) {

                    // requesting permission
                    ActivityCompat.requestPermissions(MainActivity.this,
                            new String[]{Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_CONTACTS}, storagePermissionCode);

                } else if (methodCall.method.equals("fetchFileList")) {

                    // calling function and getting list of files
                    try {

                        // gets list of files
                        List files = readFiles();

                        // returning file list to flutter
                        result.success(files);
                    } catch (FileNotFoundException e) {
                        e.printStackTrace();
                    }

                } else if (methodCall.method.equals("viewImageUnSaved")) {

                    // status image stored path
                    String statusPath = Environment.getExternalStorageDirectory().toString() + "/WhatsApp/Media/.Statuses/";

                    // getting filename passed through arguments
                    String fileName = methodCall.argument("fileName");
                    Intent intent = new Intent();
                    intent.setAction(Intent.ACTION_VIEW);
                    intent.setDataAndType(Uri.parse("file://" + statusPath + fileName), "image/*");
                    startActivity(intent);
                } else if (methodCall.method.equals("viewVideoUnSaved")) {

                    Log.d("Error", "AutoExecuted viewVideoUnSaved");
                    // status image stored path
                    String statusPath = Environment.getExternalStorageDirectory().toString() + "/WhatsApp/Media/.Statuses/";

                    // getting filename passed through arguments
                    String fileName = methodCall.argument("fileName");
                    Intent intent = new Intent();
                    intent.setAction(Intent.ACTION_VIEW);
                    intent.setDataAndType(Uri.parse("file://" + statusPath + fileName), "video/mp4");
                    startActivity(intent);
                } else if (methodCall.method.equals("getContacts")) {
                    // getting list of contacts
                    List contacts = getContacts();
                    // sending list of contacts to flutter
                    result.success(contacts);
                } else if (methodCall.method.equals("copyFile")) {

                    // getting file name and contact to save to
                    String fileName = methodCall.argument("fileName");
                    String contact = methodCall.argument("contact");

                    result.success(copyFile(fileName, contact));
                } else if (methodCall.method.equals("openGitHub")) {
                    String url = "https://github.com/RohitRajP";
                    Intent i = new Intent(Intent.ACTION_VIEW);
                    i.setData(Uri.parse(url));
                    startActivity(i);
                } else if (methodCall.method.equals("openLinkedIn")) {
                    String url = "https://linkedin.com/in/rohit-raj-p";
                    Intent i = new Intent(Intent.ACTION_VIEW);
                    i.setData(Uri.parse(url));
                    startActivity(i);
                } else if (methodCall.method.equals("openFacebook")) {
                    String url = "https://www.facebook.com/profile.php?id=100014423143431";
                    Intent i = new Intent(Intent.ACTION_VIEW);
                    i.setData(Uri.parse(url));
                    startActivity(i);
                } else if (methodCall.method.equals("shareMedia")) {

                    // getting file parameters
                    String fileName = methodCall.argument("fileName");
                    String fileType = methodCall.argument("fileType").toString();

                    // setting file path
                    String uriString = Environment.getExternalStorageDirectory().toString() + "/WhatsApp/Media/.Statuses/" + fileName;

                    // calling function to share media
                    shareMedia(fileType, uriString);
                }

            }

            private void shareMedia(String fileType, String uriString) {

                File test = new File(uriString);
                Intent sendIntent = new Intent();
                sendIntent.setAction(Intent.ACTION_SEND);
                sendIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);

                if (fileType.equals("0")) {

                    sendIntent.setType("image/jpeg");
                } else if (fileType.equals("1")) {

                    sendIntent.setType("video/mp4");
                }

                sendIntent.putExtra(Intent.EXTRA_STREAM, Uri.fromFile(test));
                startActivity(Intent.createChooser(sendIntent, "Share image using"));
            }


            private String copyFile(String fileName, String contact) {

                if (ContextCompat.checkSelfPermission(MainActivity.this, Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED && ContextCompat.checkSelfPermission(MainActivity.this, Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED) {

                    // declare directory paths for source and destination
                    String sourcePath = Environment.getExternalStorageDirectory().toString() + "/WhatsApp/Media/.Statuses/" + fileName;
                    String destinationPath = Environment.getExternalStorageDirectory() + "/StatusForever/Users/" + contact + "-Statuses/";

                    // check if file already exsists
                    String exsistance = checkFileExistance(destinationPath, fileName);

                    if (exsistance.equals("Failed")) {
                        // creating file instances for both source and destination paths
                        File sourceLocationFile = new File(sourcePath);
                        File destinationLocationDir = new File(destinationPath);
                        File destinationLocationFile = new File(destinationPath + fileName);

                        // check if the directory path of the contact exists and create if it does not
                        if (!destinationLocationDir.isDirectory()) {
                            destinationLocationDir.mkdirs();
                        }

                        try {
                            // declare input and output FileInputStreams with directories
                            InputStream in = new FileInputStream(sourceLocationFile);
                            OutputStream out = new FileOutputStream(destinationLocationFile);

                            // Copy the bits from instream to outstream
                            byte[] buf = new byte[1024];
                            int len;

                            while ((len = in.read(buf)) > 0) {
                                out.write(buf, 0, len);
                            }
                            // close streams
                            in.close();
                            out.close();
                        } catch (FileNotFoundException e) {
                            e.printStackTrace();
                        } catch (IOException e) {
                            e.printStackTrace();
                        }

                        // checking if file has been created successfully
                        exsistance = checkFileExistance(destinationPath, fileName);

                        if (exsistance.equals("Success")) {
                            return "Copied";
                        } else {
                            return "CopyFailed";
                        }

                    } else {
                        return "AlreadyExists";
                    }

                } else {
                    Toast.makeText(MainActivity.this, "Storage Read/Write Permission Error", Toast.LENGTH_SHORT).show();
                    return "Failed";
                }

            }


            private String checkFileExistance(String destinationPath, String fileName) {
                // check if file has been created in destination
                String checkPath = destinationPath + fileName;
                File checkFile = new File(checkPath);

                if (checkFile.exists()) {
                    MediaScannerConnection.scanFile(getApplicationContext(),
                            new String[]{checkFile.toString()}, null,
                            new MediaScannerConnection.OnScanCompletedListener() {
                                public void onScanCompleted(String path, Uri uri) {
                                    //Log.i("ExternalStorage", "Scanned " + path + ":");
                                    //Log.i("ExternalStorage", "-> uri=" + uri);
                                }
                            });
                    return "Success";

                } else {
                    return "Failed";
                }
            }

            private void createThumbnail(String fileName) throws FileNotFoundException {

                if (ContextCompat.checkSelfPermission(MainActivity.this, Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED && ContextCompat.checkSelfPermission(MainActivity.this, Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED) {

                    // storing path to directory to store thumbnails in
                    String statusForeverThumbPath = Environment.getExternalStorageDirectory() + "/StatusForever/";

                    // storing path to directory where the status videos are stored
                    String statusPath = Environment.getExternalStorageDirectory().toString() + "/WhatsApp/Media/.Statuses/";
                    //Log.d("BitmapPath: ",statusPath+fileName);

                    // creating thumbnail bitmap for the given file
                    Bitmap thumb = ThumbnailUtils.createVideoThumbnail(statusPath + fileName, MediaStore.Video.Thumbnails.MINI_KIND);

                    // printing bitmap information
                    //Log.d("BitMap Size: ", String.valueOf(thumb.getRowBytes()*thumb.getHeight()));

                    // editing file name to new
                    fileName = fileName.substring(0, fileName.length() - 4);
                    fileName += ".jpg";

                    //Log.d("BitmapName: ",fileName);

                    // creating file to store bitmap in folder
                    File thumbnailFile = new File(statusForeverThumbPath, fileName);

                    // checking if a thumbnail file already exists for this file
                    if (thumbnailFile.exists()) {
                        thumbnailFile.delete();
                    }

                    // creating bitmap output stream
                    FileOutputStream out = new FileOutputStream(thumbnailFile);

                    // compressing bitmap into JPEG
                    thumb.compress(Bitmap.CompressFormat.JPEG, 100, out);
                    try {
                        out.flush();
                        out.close();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                } else {
                    Toast.makeText(MainActivity.this, "Storage Read/Write Permission Error", Toast.LENGTH_SHORT).show();
                }

            }

            // reads statuses from hidden files
            private List<String> readFiles() throws FileNotFoundException {

                if (ContextCompat.checkSelfPermission(MainActivity.this, Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED && ContextCompat.checkSelfPermission(MainActivity.this, Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED) {

                    // navigating to the status path
                    String path = Environment.getExternalStorageDirectory().toString() + "/WhatsApp/Media/.Statuses";

                    // creating or getting path to access directory to store the thumbnails
                    File statusForever = new File(Environment.getExternalStorageDirectory() + "/StatusForever/");

                    // checking if the required directory exists
                    if (!statusForever.exists() && !statusForever.isDirectory()) {
                        // create empty directory
                        if (statusForever.mkdirs()) {
                            // Log.i("CreateDir", "App dir created");
                        } else {
                            //Log.w("CreateDir", "Unable to create app dir!");
                        }
                    } else {
                        //Log.i("CreateDir", "App dir already exists");
                    }


                    // logging the current location
                    //Log.d("Files", "Path: " + path);

                    // creating a directory instance in the same path
                    File directory = new File(path);

                    // getting list of files in directory to FILE array instance
                    File[] files = directory.listFiles();

                    // logging number of files in directory
                    //Log.d("Files", "Size: "+ files.length);

                    // list to hold the last modified dates of files
                    List<Date> lastModDates = new ArrayList<>();

                    // hash map to store values of files with their modified dates
                    HashMap<String, Date> hmap = new HashMap<String, Date>();

                    // date format to reformat dates if necessary
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd h:m");

                    // looping through all the files
                    if (files.length > 0) {
                        for (int i = 0; i < files.length; i++) {

                            // getting the last modified dates of file
                            Date lastModDate = new Date(files[i].lastModified());
//
//                            // adding the date to variable
//                            lastModDates.add(lastModDate);

                            hmap.put(files[i].toString(),lastModDate);

                            // creating thumbnails for files if it is a video
                            if (files[i].getName().substring(32).equals(".mp4")) {
                                createThumbnail(files[i].getName());
                            }
                        }

                        // loop to sort hashmap
                        for(int i=0;i<files.length;i++){
                            hmap.
                        }



                        // storing file list in array
                        List<String> stauses = Arrays.asList(directory.list());

                        return stauses;
                    } else {
                        return null;
                    }
                } else {
                    Toast.makeText(MainActivity.this, "Storage Read/Write Permission Error", Toast.LENGTH_SHORT).show();
                    return null;
                }

            }

        });
    }

    private List<String> getContacts() {

        if (ContextCompat.checkSelfPermission(MainActivity.this, Manifest.permission.READ_CONTACTS) == PackageManager.PERMISSION_GRANTED) {
            ArrayList<String> contacts = new ArrayList<>();

            // creating ContentResolver instance
            ContentResolver contentResolver = getContentResolver();

            // creating cursor instance to fetch all contacts
            Cursor cursor = getContentResolver().query(ContactsContract.CommonDataKinds.Phone.CONTENT_URI, null, null, null, null);

            // looping through contacts
            while (cursor.moveToNext()) {
                contacts.add(cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME)));
            }

            // closing cursor
            cursor.close();


            return contacts;
        } else {
            Toast.makeText(MainActivity.this, "Contacts Permission Error", Toast.LENGTH_SHORT).show();
            return null;
        }

    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        if (requestCode == storagePermissionCode) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED && grantResults[2] == PackageManager.PERMISSION_GRANTED) {
                Toast.makeText(this, "Awesome! Let's get started", Toast.LENGTH_SHORT).show();
                MethodChannel channel = new MethodChannel(getFlutterView(), CHANNEL_ID);
                channel.invokeMethod("permissionGranted", "true");
            } else {
                MethodChannel channel = new MethodChannel(getFlutterView(), CHANNEL_ID);
                channel.invokeMethod("permissionGranted", "false");
                Toast.makeText(this, "App functionality limited without core permissions", Toast.LENGTH_LONG).show();
            }
        }
    }

}
