
component {

    // Wrapper around jBCrypt
    public string function hash(required string password) {
        var jbcrypt = createObject("java","org.mindrot.jbcrypt.BCrypt");
        return jbcrypt.hashpw(password, jbcrypt.gensalt(12));
    }

    public boolean function check(required string password, required string hash) {
        var jbcrypt = createObject("java","org.mindrot.jbcrypt.BCrypt");
        return jbcrypt.checkpw(password, hash);
    }

}