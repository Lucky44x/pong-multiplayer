class SoundManager {
  private HashMap<String, SoundFile> sounds = new HashMap<>();

  public void loadFiles() {
    File folder = new File(dataPath("sounds"));
    if (!folder.exists()){
       return;
    }
      
    File[] allFiles = folder.listFiles(new FilenameFilter(){
       public boolean accept(File dir, String name) {return name.toLowerCase().endsWith(".wav");} 
    });
    
    for(File f : allFiles){
        sounds.put(f.getName().split("\\.")[0], new SoundFile(pongClient.this, f.getAbsolutePath()));
    }
  }
  
  public void playSound(String id){
     sounds.get(id).play(); 
  }
}
