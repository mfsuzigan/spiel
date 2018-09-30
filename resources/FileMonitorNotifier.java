private class FileMonitorNotifier extends TimerTask
  {    
    public void run()
    {  
      // Loop over the registered files and see which have changed.
      // Use a copy of the list in case listener wants to alter the
      // list within its fileChanged method.
      Collection files = new ArrayList (files_.keySet());
       
      for (Iterator i = files.iterator(); i.hasNext(); ) {
        File file = (File) i.next();
        long lastModifiedTime = ((Long) files_.get (file)).longValue();
        long newModifiedTime  = file.exists() ? file.lastModified() : -1;
       
        // Chek if file has changed
        if (newModifiedTime != lastModifiedTime) {
       
          // Register new modified time
          files_.put (file, new Long (newModifiedTime));
       
          // Notify listeners
          for (Iterator j = listeners_.iterator(); j.hasNext(); ) {
            WeakReference reference = (WeakReference) j.next();
            FileListener listener = (FileListener) reference.get();
       
            // Remove from list if the back-end object has been GC'd
            if (listener == null)
              j.remove();
            else
              listener.fileChanged (file);
          }
        }
      }
    }  
  }    