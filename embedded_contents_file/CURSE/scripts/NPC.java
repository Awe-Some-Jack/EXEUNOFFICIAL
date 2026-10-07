public class NPC {
    public String tag;
    public int dancePerBeats = 2;
    public int beatProgress = -1;
    public String curState = "DANCE";
    public double animTimer = 2;
    public NPC (String[] args){
        System.out.println("NPC "+tag);
        switch (curState) {
            case "DANCE":
                break;
            case "STATIC":
                break;
            case "ACTION":
                switch (tag){
                    case "abuelita":
                        System.out.println("abuelita gruñonaaa");
                        break;
                    case "reportera":
                        System.out.println("entrevistando hmmmm");
                }
                break;
            default:
                break;
        }
    }

    public void onBeatHit(int beats){
        beatProgress += beats;

        if (curState == "DANCE"){
            if (beats % 2 == 0){
                System.out.println("dance dance dancing");
            }
        }
    }
}