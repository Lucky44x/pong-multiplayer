class SoundManager {
  private HashMap<String, SoundFile> sounds = new HashMap<>();

  public void loadFiles() {
    File folder = new File(dataPath("sounds"));
    if (!folder.exists()){
       return;
    }
      
    File[] allFiles = folder.listFiles(new FilenameFilter(){
       public boolean accept(File dir, String name) {println(name); return name.toLowerCase().endsWith(".wav");} 
    });
    
    for(File f : allFiles){
        sounds.put(f.getName().split("\\.")[0], new SoundFile(pongClient.this, f.getAbsolutePath()));
    }
  }
  
  public void playSound(String id){
    
     for(String k : sounds.keySet()){
        println(k); 
     }
    
     sounds.get(id).play(); 
  }
  
  public void playRandomBlip(){
    int i = (int)random(0,2);
    playSound("blip-" + i);
  }
}
