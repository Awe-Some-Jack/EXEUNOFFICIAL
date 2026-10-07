public class NPC {
    public String tag;
    public int dancePerBeats = 2;
    public int beatProgress = -1;

    public static void main(String[] args){

    }

    public void onBeatHit(int beats){
        beatProgress += beats;
    }
}