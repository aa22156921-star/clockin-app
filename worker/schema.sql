-- clockin D1 完整結構（2026-11-28 由正式資料庫匯出）。重建資料庫：wrangler d1 execute <db> --file=worker/schema.sql

CREATE TABLE IF NOT EXISTS align_log (date TEXT PRIMARY KEY, score REAL, a_staff REAL, b_sched REAL, c_site REAL, d_att REAL, detail TEXT, created_ms INTEGER);

CREATE TABLE IF NOT EXISTS audit (id INTEGER PRIMARY KEY AUTOINCREMENT, ms INTEGER NOT NULL, actor TEXT NOT NULL, action TEXT NOT NULL, detail TEXT);

CREATE TABLE IF NOT EXISTS bind_fail (ip TEXT PRIMARY KEY, n INTEGER NOT NULL, until INTEGER NOT NULL);

CREATE TABLE IF NOT EXISTS dept_map (dept_id TEXT PRIMARY KEY, dept_name TEXT NOT NULL, code TEXT, site_id INTEGER, mode TEXT NOT NULL DEFAULT 'site', leader_uid TEXT);

CREATE TABLE IF NOT EXISTS devices (id INTEGER PRIMARY KEY AUTOINCREMENT, emp_id INTEGER NOT NULL, device_hash TEXT NOT NULL UNIQUE, ua TEXT, bound_at TEXT NOT NULL);

CREATE TABLE IF NOT EXISTS dup_resolve (emp_no TEXT PRIMARY KEY, name TEXT, keep_no TEXT, reason TEXT, decided_ms INTEGER, nueip_done INTEGER DEFAULT 0);

CREATE TABLE IF NOT EXISTS employees (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE, site_id INTEGER, active INTEGER NOT NULL DEFAULT 1, reg_code TEXT NOT NULL, device_hash TEXT, bound_at TEXT, bound_ua TEXT, consent_at TEXT, created_at TEXT NOT NULL, max_devices INTEGER NOT NULL DEFAULT 2, emp_no TEXT, auto_ping TEXT, locate_req INTEGER, roam INTEGER NOT NULL DEFAULT 0, nueip_uid TEXT, nueip_dept TEXT, viewer INTEGER NOT NULL DEFAULT 0);

CREATE TABLE IF NOT EXISTS files (name TEXT PRIMARY KEY, data TEXT NOT NULL, mime TEXT NOT NULL, size INTEGER NOT NULL, version TEXT, updated_at TEXT NOT NULL);

CREATE TABLE IF NOT EXISTS idv (name TEXT NOT NULL, h TEXT NOT NULL, PRIMARY KEY (name, h));

CREATE TABLE IF NOT EXISTS ins_grade (kind TEXT NOT NULL, year INTEGER NOT NULL, salary INTEGER NOT NULL, emp_amt INTEGER, er_amt INTEGER, gov_amt INTEGER, PRIMARY KEY (kind, year, salary));

CREATE TABLE IF NOT EXISTS leave_balance (emp_no TEXT NOT NULL, leave_type TEXT NOT NULL, year INTEGER NOT NULL, period_start TEXT, period_end TEXT, grant_min INTEGER DEFAULT 0, used_min INTEGER DEFAULT 0, remain_min INTEGER, expire_date TEXT, source TEXT, imported_ms INTEGER, PRIMARY KEY (emp_no, leave_type, year));

CREATE TABLE IF NOT EXISTS leave_types (id TEXT PRIMARY KEY, name TEXT NOT NULL, sort INTEGER NOT NULL DEFAULT 50);

CREATE TABLE IF NOT EXISTS nueip_diff (date TEXT NOT NULL, emp_no TEXT NOT NULL, name TEXT, admin_in TEXT, admin_out TEXT, nueip_in TEXT, nueip_out TEXT, nueip_method TEXT, status TEXT, exported_ms INTEGER, checked_ms INTEGER, PRIMARY KEY (date, emp_no));

CREATE TABLE IF NOT EXISTS pay_calc_member (period TEXT NOT NULL, name TEXT NOT NULL, dept TEXT NOT NULL DEFAULT '', title TEXT, status TEXT, base REAL, daily REAL, duty REAL, full_att REAL, perf REAL, other REAL, days REAL, src_period TEXT, added_ms INTEGER, sched_days REAL, att_days REAL, leave_days REAL, att_ms INTEGER, grade REAL, labor_x INTEGER DEFAULT 0, health_x INTEGER DEFAULT 0, dependents INTEGER DEFAULT 0, health_grade REAL, health_fix REAL, pension_self REAL, ins_src TEXT, PRIMARY KEY (period, name, dept));

CREATE TABLE IF NOT EXISTS pay_period (period TEXT PRIMARY KEY, status TEXT NOT NULL DEFAULT 'draft', note TEXT, created_ms INTEGER, calc_ms INTEGER, locked_ms INTEGER, locked_by TEXT);

CREATE TABLE IF NOT EXISTS pay_profile (emp_no TEXT PRIMARY KEY, name TEXT, pay_type TEXT NOT NULL DEFAULT '月薪', base INTEGER DEFAULT 0, hourly INTEGER, daily INTEGER, duty_allow INTEGER DEFAULT 0, night_allow INTEGER DEFAULT 0, other_allow TEXT, labor_salary INTEGER, health_salary INTEGER, pension_salary INTEGER, pension_self_pct REAL DEFAULT 0, health_dependents INTEGER DEFAULT 0, bank TEXT, effective_from TEXT, source TEXT, updated_ms INTEGER);

CREATE TABLE IF NOT EXISTS pay_rule (k TEXT PRIMARY KEY, v TEXT NOT NULL, note TEXT, updated_ms INTEGER);

CREATE TABLE IF NOT EXISTS pay_rule_assign (name TEXT NOT NULL, dept TEXT NOT NULL DEFAULT '', rule_id INTEGER NOT NULL, updated_ms INTEGER, PRIMARY KEY (name, dept));

CREATE TABLE IF NOT EXISTS pay_rule_def (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, kind TEXT NOT NULL, params TEXT NOT NULL DEFAULT '{}', note TEXT, updated_ms INTEGER);

CREATE TABLE IF NOT EXISTS pay_struct (id INTEGER PRIMARY KEY AUTOINCREMENT, period TEXT NOT NULL, name TEXT NOT NULL, dept TEXT, title TEXT, status TEXT, base REAL, daily REAL, duty REAL, full_att REAL, perf REAL, other REAL, days REAL, net REAL, grade REAL, created_at TEXT DEFAULT (datetime('now')), note TEXT, UNIQUE(period,name,dept));

CREATE TABLE IF NOT EXISTS payroll_draft (period TEXT NOT NULL, emp_no TEXT NOT NULL, name TEXT, site TEXT, sched_days INTEGER, sched_min INTEGER, work_days INTEGER, work_min INTEGER, ot_min INTEGER, late_min INTEGER, early_min INTEGER, miss_in INTEGER, miss_out INTEGER, absent_days INTEGER, leave_json TEXT, base INTEGER, allow INTEGER, ot_pay INTEGER, leave_deduct INTEGER, other_deduct INTEGER, labor INTEGER, health INTEGER, pension_self INTEGER, gross INTEGER, net INTEGER, manual_json TEXT, flags TEXT, calc_ms INTEGER, confirmed_by TEXT, confirmed_ms INTEGER, PRIMARY KEY (period, emp_no));

CREATE TABLE IF NOT EXISTS pings (id INTEGER PRIMARY KEY AUTOINCREMENT, emp_id INTEGER NOT NULL, ms INTEGER NOT NULL, lat REAL, lng REAL, acc REAL, err TEXT, ip TEXT, ua TEXT, kind TEXT);

CREATE TABLE IF NOT EXISTS punches (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, site_id INTEGER NOT NULL, site_name TEXT NOT NULL, type TEXT NOT NULL, lat REAL NOT NULL, lng REAL NOT NULL, accuracy REAL NOT NULL, distance REAL NOT NULL, status TEXT NOT NULL, ip TEXT, ua TEXT, created_at TEXT NOT NULL, date_tw TEXT NOT NULL, time_tw TEXT NOT NULL);

CREATE TABLE IF NOT EXISTS requests (id INTEGER PRIMARY KEY AUTOINCREMENT, emp_id INTEGER NOT NULL, kind TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'pending', date TEXT NOT NULL, date_to TEXT, io TEXT, time TEXT, time_to TEXT, leave_type TEXT, reason TEXT,
      lat REAL, lng REAL, acc REAL, created_ms INTEGER NOT NULL, decided_ms INTEGER, decided_by TEXT, note TEXT, place_lat REAL, place_lng REAL);

CREATE TABLE IF NOT EXISTS schedule (emp_id INTEGER NOT NULL, date TEXT NOT NULL, shift_code TEXT NOT NULL, site_id INTEGER, PRIMARY KEY (emp_id, date));

CREATE TABLE IF NOT EXISTS shifts (code TEXT PRIMARY KEY, name TEXT NOT NULL, start TEXT NOT NULL, end TEXT NOT NULL);

CREATE TABLE IF NOT EXISTS sites (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, lat REAL NOT NULL, lng REAL NOT NULL, radius INTEGER NOT NULL DEFAULT 200, active INTEGER NOT NULL DEFAULT 1, created_at TEXT NOT NULL);

CREATE TABLE IF NOT EXISTS staff (uid TEXT PRIMARY KEY, emp_no TEXT NOT NULL, name TEXT NOT NULL, dept_id TEXT, dept_name TEXT, title TEXT, arrive TEXT, active INTEGER NOT NULL DEFAULT 1, synced_ms INTEGER, gender TEXT, age INTEGER, work_type TEXT, country TEXT, military TEXT, marriage TEXT, identity TEXT, email TEXT, status TEXT);

CREATE INDEX IF NOT EXISTS idx_deptmap_name ON dept_map(dept_name);

CREATE INDEX IF NOT EXISTS idx_devices_emp ON devices(emp_id);

CREATE INDEX IF NOT EXISTS idx_emp_active ON employees(active);

CREATE UNIQUE INDEX IF NOT EXISTS idx_emp_device ON employees(device_hash);

CREATE INDEX IF NOT EXISTS idx_emp_no ON employees(emp_no COLLATE NOCASE);

CREATE INDEX IF NOT EXISTS idx_emp_nueip ON employees(nueip_uid);

CREATE INDEX IF NOT EXISTS idx_emp_site ON employees(site_id);

CREATE INDEX IF NOT EXISTS idx_idv_h ON idv(h);

CREATE INDEX IF NOT EXISTS idx_pings_emp_ms ON pings(emp_id, ms);

CREATE INDEX IF NOT EXISTS idx_pings_ms ON pings(ms);

CREATE INDEX IF NOT EXISTS idx_punches_date ON punches(date_tw);

CREATE INDEX IF NOT EXISTS idx_punches_name ON punches(name, type, created_at);

CREATE INDEX IF NOT EXISTS idx_requests_emp ON requests(emp_id, date);

CREATE INDEX IF NOT EXISTS idx_requests_kind ON requests(kind, status, date);

CREATE INDEX IF NOT EXISTS idx_requests_status ON requests(status);

CREATE INDEX IF NOT EXISTS idx_schedule_date ON schedule(date);

CREATE INDEX IF NOT EXISTS idx_schedule_site_date ON schedule(site_id, date);

CREATE INDEX IF NOT EXISTS idx_sites_name ON sites(name);

CREATE INDEX IF NOT EXISTS idx_staff_dept ON staff(dept_id, active);

CREATE INDEX IF NOT EXISTS idx_staff_name ON staff(name);

CREATE INDEX IF NOT EXISTS idx_staff_no ON staff(emp_no COLLATE NOCASE);

CREATE INDEX IF NOT EXISTS idx_staff_uid_active ON staff(active);

DROP VIEW IF EXISTS att_monthly;
DROP VIEW IF EXISTS att_daily;
CREATE VIEW att_daily AS
WITH sch AS (
  SELECT s.emp_id, s.date, s.shift_code, s.site_id, sh.start, sh.end,
    CAST(strftime('%s', s.date||' '||sh.start) AS INTEGER)*1000 - 28800000 AS st_ms,
    CAST(strftime('%s', s.date||' '||sh.end) AS INTEGER)*1000 - 28800000 + CASE WHEN sh.end <= sh.start THEN 86400000 ELSE 0 END AS en_ms
  FROM schedule s JOIN shifts sh ON sh.code = s.shift_code),
ev AS (
  -- 出勤只算「上班／下班」紀錄（自己按的，或有排班在排班案場範圍內自動判定的）且在案場範圍內（幹部／機動不比對案場）
  SELECT p.emp_id, p.ms, p.kind AS io FROM pings p JOIN employees e ON e.id = p.emp_id
   WHERE p.kind IN ('in','out') AND p.lat IS NOT NULL
     AND (coalesce(e.roam,0)=1 OR coalesce(e.auto_ping,'') NOT IN ('','不追蹤') OR EXISTS (
       SELECT 1 FROM sites st WHERE st.active=1 AND st.lat IS NOT NULL
         AND 6371000*sqrt(radians(p.lat-st.lat)*radians(p.lat-st.lat) + (radians(p.lng-st.lng)*cos(radians(st.lat)))*(radians(p.lng-st.lng)*cos(radians(st.lat)))) <= coalesce(st.radius,200)))),
fx AS (
  -- 核准的補卡：依「申請的班別日期」對應，夜班的下班時間落在隔天（與後台出勤報表同一規則）
  SELECT sch.emp_id, sch.date,
    (SELECT min(CAST(strftime('%s', r.date||' '||r.time) AS INTEGER)*1000 - 28800000
                + CASE WHEN CAST(strftime('%s', r.date||' '||r.time) AS INTEGER)*1000 - 28800000 < sch.st_ms - 43200000 THEN 86400000 ELSE 0 END)
       FROM requests r WHERE r.emp_id=sch.emp_id AND r.kind='punch' AND r.status='approved' AND r.io='in' AND r.date=sch.date AND r.time IS NOT NULL) AS fin,
    (SELECT max(CAST(strftime('%s', r.date||' '||r.time) AS INTEGER)*1000 - 28800000
                + CASE WHEN CAST(strftime('%s', r.date||' '||r.time) AS INTEGER)*1000 - 28800000 < sch.st_ms THEN 86400000 ELSE 0 END)
       FROM requests r WHERE r.emp_id=sch.emp_id AND r.kind='punch' AND r.status='approved' AND r.io='out' AND r.date=sch.date AND r.time IS NOT NULL) AS fout
  FROM sch),
j0 AS (
  SELECT sch.*,
    (SELECT min(ms) FROM ev WHERE ev.emp_id=sch.emp_id AND ev.io='in'  AND ev.ms BETWEEN sch.st_ms-10800000 AND sch.en_ms) AS pin,
    (SELECT max(ms) FROM ev WHERE ev.emp_id=sch.emp_id AND ev.io='out' AND ev.ms BETWEEN sch.st_ms AND sch.en_ms+21600000) AS pout,
    (SELECT r.leave_type FROM requests r WHERE r.emp_id=sch.emp_id AND r.kind='leave' AND r.status='approved'
       AND sch.date BETWEEN r.date AND coalesce(r.date_to, r.date) ORDER BY (r.time IS NULL) DESC LIMIT 1) AS leave_type,
    -- 整天請假（沒有填時段）才把這天算成「請假」；只請幾小時的，這天仍依打卡算出勤
    (SELECT count(*) FROM requests r WHERE r.emp_id=sch.emp_id AND r.kind='leave' AND r.status='approved'
       AND sch.date BETWEEN r.date AND coalesce(r.date_to, r.date) AND r.time IS NULL) > 0 AS leave_full
  FROM sch),
j AS (
  -- 上班取最早（打卡或補卡）、下班取最晚
  SELECT j0.*, CASE WHEN j0.pin IS NULL THEN fx.fin WHEN fx.fin IS NULL THEN j0.pin ELSE min(j0.pin, fx.fin) END AS in_ms,
               CASE WHEN j0.pout IS NULL THEN fx.fout WHEN fx.fout IS NULL THEN j0.pout ELSE max(j0.pout, fx.fout) END AS out_ms
  FROM j0 JOIN fx ON fx.emp_id = j0.emp_id AND fx.date = j0.date)
SELECT j.emp_id, e.emp_no, e.name, j.date, j.shift_code, j.site_id, j.start, j.end,
  (j.en_ms - j.st_ms)/60000 AS sched_min,
  strftime('%H:%M', j.in_ms/1000 + 28800, 'unixepoch') AS in_tw,
  strftime('%H:%M', j.out_ms/1000 + 28800, 'unixepoch') AS out_tw,
  CASE WHEN j.in_ms IS NOT NULL AND j.out_ms IS NOT NULL AND j.out_ms > j.in_ms THEN (min(j.out_ms, j.en_ms) - max(j.in_ms, j.st_ms))/60000 END AS work_min,
  CASE WHEN j.out_ms > j.en_ms THEN (j.out_ms - j.en_ms)/60000 ELSE 0 END AS after_min,
  CASE WHEN j.in_ms > j.st_ms THEN (j.in_ms - j.st_ms)/60000 ELSE 0 END AS late_min,
  CASE WHEN j.out_ms IS NOT NULL AND j.out_ms < j.en_ms THEN (j.en_ms - j.out_ms)/60000 ELSE 0 END AS early_min,
  (j.in_ms IS NULL) AS miss_in, (j.out_ms IS NULL) AS miss_out,
  -- 假別名稱：對得到假別表用表上名稱，對不到（假別改名、停用）也照樣算請假，不會變成未打卡
  coalesce((SELECT lt.name FROM leave_types lt WHERE lt.id = j.leave_type OR lt.name = j.leave_type LIMIT 1), j.leave_type) AS leave_name,
  CASE WHEN j.leave_full THEN '請假' WHEN j.in_ms IS NULL AND j.out_ms IS NULL THEN '未打卡' WHEN j.in_ms IS NULL OR j.out_ms IS NULL THEN '缺卡' ELSE '正常' END AS day_status
FROM j JOIN employees e ON e.id = j.emp_id;

CREATE VIEW att_monthly AS
SELECT substr(date,1,7) AS period, emp_id, emp_no, name,
  count(*) AS sched_days, sum(sched_min) AS sched_min,
  sum(day_status='正常') AS ok_days, sum(day_status='缺卡') AS partial_days, sum(day_status='未打卡') AS nopunch_days, sum(day_status='請假') AS leave_days,
  coalesce(sum(work_min),0) AS work_min, sum(after_min) AS after_min, sum(late_min) AS late_min, sum(early_min) AS early_min,
  sum(miss_in) AS miss_in, sum(miss_out) AS miss_out,
  (SELECT json_group_object(leave_name, c) FROM (SELECT leave_name, count(*) c FROM att_daily a2 WHERE a2.emp_id=att_daily.emp_id AND substr(a2.date,1,7)=substr(att_daily.date,1,7) AND leave_name IS NOT NULL GROUP BY leave_name)) AS leave_json
FROM att_daily GROUP BY substr(date,1,7), emp_id;
