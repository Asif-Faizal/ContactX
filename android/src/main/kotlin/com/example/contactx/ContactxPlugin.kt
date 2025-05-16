package com.example.contactx

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.database.Cursor
import android.provider.ContactsContract
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** ContactxPlugin */
class ContactxPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "contactx")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "getContacts" -> {
        try {
          val contacts = getDeviceContacts()
          result.success(contacts)
        } catch (e: Exception) {
          result.error("CONTACTS_ERROR", "Failed to get contacts: ${e.message}", null)
        }
      }
      "checkPermission" -> {
        val permissionStatus = checkContactPermission()
        result.success(permissionStatus)
      }
      else -> {
        result.notImplemented()
      }
    }
  }
  
  private fun checkContactPermission(): String {
    val permission = Manifest.permission.READ_CONTACTS
    val granted = ContextCompat.checkSelfPermission(context, permission) == PackageManager.PERMISSION_GRANTED
    
    return if (granted) {
      "authorized"
    } else {
      "denied"
    }
  }
  
  private fun cleanPhoneNumber(phoneNumber: String): String {
    return phoneNumber.replace(Regex("[\\s\\-\\(\\)]"), "")
  }

  private fun getDeviceContacts(): List<Map<String, String>> {
    val contacts = mutableListOf<Map<String, String>>()
    
    val permission = Manifest.permission.READ_CONTACTS
    val granted = ContextCompat.checkSelfPermission(context, permission) == PackageManager.PERMISSION_GRANTED
    
    if (!granted) {
      throw SecurityException("Permission to read contacts was denied")
    }
    
    val projection = arrayOf(
      ContactsContract.Contacts._ID,
      ContactsContract.Contacts.DISPLAY_NAME,
      ContactsContract.Contacts.HAS_PHONE_NUMBER
    )
    
    val cursor: Cursor? = context.contentResolver.query(
      ContactsContract.Contacts.CONTENT_URI,
      projection,
      null,
      null,
      ContactsContract.Contacts.DISPLAY_NAME + " ASC"
    )
    
    cursor?.use { contactCursor ->
      while (contactCursor.moveToNext()) {
        val idIndex = contactCursor.getColumnIndex(ContactsContract.Contacts._ID)
        val nameIndex = contactCursor.getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME)
        val hasPhoneIndex = contactCursor.getColumnIndex(ContactsContract.Contacts.HAS_PHONE_NUMBER)
        
        if (idIndex < 0 || nameIndex < 0 || hasPhoneIndex < 0) continue
        
        val id = contactCursor.getString(idIndex)
        val name = contactCursor.getString(nameIndex) ?: ""
        val hasPhoneNumber = contactCursor.getInt(hasPhoneIndex) > 0
        
        if (hasPhoneNumber) {
          val phoneCursor = context.contentResolver.query(
            ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
            arrayOf(ContactsContract.CommonDataKinds.Phone.NUMBER),
            ContactsContract.CommonDataKinds.Phone.CONTACT_ID + " = ?",
            arrayOf(id),
            null
          )
          
          phoneCursor?.use { 
            if (phoneCursor.moveToNext()) {
              val numberIndex = phoneCursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER)
              if (numberIndex >= 0) {
                val phoneNumber = phoneCursor.getString(numberIndex) ?: ""
                val cleanedNumber = cleanPhoneNumber(phoneNumber)
                contacts.add(mapOf("name" to name, "number" to cleanedNumber))
              }
            }
          }
        }
      }
    }
    
    return contacts
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
