package tw.clockin.app;

import android.content.Context;
import android.webkit.CookieManager;

import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

/** 和打卡伺服器溝通。裝置身分沿用網頁綁定時存下的 ck_dev cookie。 */
final class Api {
    static final String BASE = BuildConfig.BASE_URL;

    private Api() {}

    /** 從 WebView 的 cookie 取出綁定用的裝置代碼（取不到就用上次存下的）；尚未綁定回傳 null。 */
    static String deviceToken(Context ctx) {
        String t = cookieToken();
        android.content.SharedPreferences sp = ctx.getSharedPreferences("clockin", Context.MODE_PRIVATE);
        if (t != null) { if (!t.equals(sp.getString("token", null))) sp.edit().putString("token", t).apply(); return t; }
        return sp.getString("token", null);
    }

    /** 網頁顯示解除綁定（401）時清掉存下的代碼。 */
    static void clearToken(Context ctx) {
        ctx.getSharedPreferences("clockin", Context.MODE_PRIVATE).edit().remove("token").apply();
    }

    private static String cookieToken() {
        try {
            String all = CookieManager.getInstance().getCookie(BASE);
            if (all == null) return null;
            for (String part : all.split(";")) {
                String p = part.trim();
                if (p.startsWith("ck_dev=")) {
                    String v = p.substring(7);
                    return v.matches("[0-9a-f]{64}") ? v : null;
                }
            }
        } catch (Throwable ignored) { }
        return null;
    }

    static JSONObject get(Context ctx, String path) throws Exception {
        return request(ctx, "GET", path, null);
    }

    static JSONObject post(Context ctx, String path, JSONObject body) throws Exception {
        return request(ctx, "POST", path, body.toString());
    }

    private static JSONObject request(Context ctx, String method, String path, String body) throws Exception {
        String token = deviceToken(ctx);
        HttpURLConnection c = (HttpURLConnection) new URL(BASE + path).openConnection();
        c.setRequestMethod(method);
        c.setConnectTimeout(15000);
        c.setReadTimeout(20000);
        c.setRequestProperty("Content-Type", "application/json");
        c.setRequestProperty("User-Agent", "ClockinApp/" + BuildConfig.VERSION_NAME + " (Android background)");
        if (token != null) {
            c.setRequestProperty("X-Device", token);
            c.setRequestProperty("Cookie", "ck_dev=" + token);
        }
        if (body != null) {
            c.setDoOutput(true);
            try (OutputStream os = c.getOutputStream()) { os.write(body.getBytes(StandardCharsets.UTF_8)); }
        }
        int code = c.getResponseCode();
        InputStream in = code >= 400 ? c.getErrorStream() : c.getInputStream();
        String text = "";
        if (in != null) {
            ByteArrayOutputStream buf = new ByteArrayOutputStream();
            byte[] b = new byte[4096]; int n;
            while ((n = in.read(b)) > 0) buf.write(b, 0, n);
            in.close();
            text = buf.toString("UTF-8");
        }
        c.disconnect();
        JSONObject j = text.isEmpty() ? new JSONObject() : new JSONObject(text);
        if (code == 401 && path.equals("/api/ping")) clearToken(ctx);
        j.put("_status", code);
        return j;
    }
}
