public with sharing class CheckRecursiveCallbacktrigger {
    private static boolean run = true;
    public static boolean runOnce() {
        if (run) {
            run = false;
            return true;
        } else {
            return run;
        }
    }

    private static boolean runBefore = true;
    public static boolean runOnceBefore() {
        if (runBefore) {
            runBefore = false;
            return true;
        } else {
            return runBefore;
        }
    }

    private static boolean runAfter = true;
    public static boolean runOnceAfter() {
        if (runAfter) {
            runAfter = false;
            return true;
        } else {
            return runAfter;
        }
    }
}
