-- 1. Branches Table
CREATE TABLE IF NOT EXISTS branches (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    background_image TEXT,
    header_image TEXT,
    address TEXT,
    phone TEXT,
    opening_hours TEXT,
    description TEXT
);

-- 2. Breeds Table
CREATE TABLE IF NOT EXISTS breeds (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

-- 3. Employees Table
CREATE TABLE IF NOT EXISTS employees (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    role TEXT NOT NULL, -- 'admin', 'manager', 'supervisor', 'staff'
    branch_id INTEGER REFERENCES branches(id) ON DELETE SET NULL,
    avatar TEXT,
    username TEXT UNIQUE,
    password TEXT
);

-- 4. Cats Table
CREATE TABLE IF NOT EXISTS cats (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    breed_id INTEGER REFERENCES breeds(id) ON DELETE SET NULL,
    branch_id INTEGER REFERENCES branches(id) ON DELETE SET NULL,
    birth_date TEXT,
    weight NUMERIC,
    vaccine_expiry TEXT,
    status TEXT DEFAULT 'normal', -- 'normal', 'observation', 'sick'
    photo TEXT,
    medical_history TEXT,
    needs_medication BOOLEAN DEFAULT false,
    can_bathe BOOLEAN DEFAULT true,
    needs_bathe BOOLEAN DEFAULT false,
    is_neutered BOOLEAN DEFAULT false,
    gender TEXT DEFAULT 'male',
    lastUpdated TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Vaccine Categories Table
CREATE TABLE IF NOT EXISTS vaccine_categories (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    type TEXT NOT NULL -- 'vaccine', 'deworming'
);

-- 6. Cat Vaccines Table
CREATE TABLE IF NOT EXISTS cat_vaccines (
    id SERIAL PRIMARY KEY,
    cat_id INTEGER REFERENCES cats(id) ON DELETE CASCADE,
    category_id INTEGER REFERENCES vaccine_categories(id) ON DELETE CASCADE,
    start_date TEXT,
    end_date TEXT,
    is_completed BOOLEAN DEFAULT false,
    completed_at TEXT,
    completed_by INTEGER REFERENCES employees(id) ON DELETE SET NULL
);

-- 7. Weight Records Table
CREATE TABLE IF NOT EXISTS weight_records (
    id SERIAL PRIMARY KEY,
    cat_id INTEGER REFERENCES cats(id) ON DELETE CASCADE,
    weight NUMERIC,
    date TEXT
);

-- 8. Medication Plans Table
CREATE TABLE IF NOT EXISTS medication_plans (
    id SERIAL PRIMARY KEY,
    cat_id INTEGER REFERENCES cats(id) ON DELETE CASCADE,
    name TEXT,
    dosage TEXT DEFAULT '',
    days INTEGER,
    frequency TEXT,
    timing TEXT, -- 'before', 'after'
    start_date TIMESTAMPTZ,
    end_date TEXT,
    needs_nebulization BOOLEAN DEFAULT false,
    needs_oxygen BOOLEAN DEFAULT false,
    note TEXT
);

-- 9. Role Permissions Table
CREATE TABLE IF NOT EXISTS role_permissions (
    role TEXT PRIMARY KEY,
    permissions JSONB -- Store permissions as JSONB
);

-- 10. Medication Logs Table
CREATE TABLE IF NOT EXISTS medication_logs (
    id SERIAL PRIMARY KEY,
    cat_id INTEGER REFERENCES cats(id) ON DELETE CASCADE,
    employee_id INTEGER REFERENCES employees(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    note TEXT
);

-- 11. Settings Table
CREATE TABLE IF NOT EXISTS settings (
    key TEXT PRIMARY KEY,
    value TEXT
);

-- 12. Attendance Table
CREATE TABLE IF NOT EXISTS attendance (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER REFERENCES employees(id) ON DELETE CASCADE,
    type TEXT, -- 'clock_in', 'clock_out'
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 13. Bath Logs Table
CREATE TABLE IF NOT EXISTS bath_logs (
    id SERIAL PRIMARY KEY,
    cat_id INTEGER REFERENCES cats(id) ON DELETE CASCADE,
    employee_id INTEGER REFERENCES employees(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    is_completed BOOLEAN DEFAULT false,
    completed_at TIMESTAMPTZ,
    completed_by INTEGER REFERENCES employees(id) ON DELETE SET NULL,
    note TEXT
);

-- 14. Care Logs Table
CREATE TABLE IF NOT EXISTS care_logs (
    id SERIAL PRIMARY KEY,
    cat_id INTEGER REFERENCES cats(id) ON DELETE CASCADE,
    care_type TEXT,
    employee_id INTEGER REFERENCES employees(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    note TEXT
);

-- 15. Cat Edit Logs Table
CREATE TABLE IF NOT EXISTS cat_edit_logs (
    id SERIAL PRIMARY KEY,
    cat_id INTEGER REFERENCES cats(id) ON DELETE CASCADE,
    employee_id INTEGER REFERENCES employees(id) ON DELETE SET NULL,
    changes JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 16. Tasks Table
CREATE TABLE IF NOT EXISTS tasks (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    priority TEXT DEFAULT 'medium', -- 'low', 'medium', 'high'
    status TEXT DEFAULT 'pending', -- 'pending', 'in_progress', 'completed'
    assigned_to INTEGER REFERENCES employees(id) ON DELETE SET NULL,
    created_by INTEGER REFERENCES employees(id) ON DELETE SET NULL,
    due_date TEXT,
    branch_id INTEGER REFERENCES branches(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 17. Vet Visits Table
CREATE TABLE IF NOT EXISTS vet_visits (
    id SERIAL PRIMARY KEY,
    cat_id INTEGER REFERENCES cats(id) ON DELETE CASCADE,
    condition TEXT NOT NULL,
    requested_by INTEGER REFERENCES employees(id) ON DELETE SET NULL,
    request_date TEXT,
    authorized_to INTEGER REFERENCES employees(id) ON DELETE SET NULL,
    authorized_by INTEGER REFERENCES employees(id) ON DELETE SET NULL,
    clinic_name TEXT,
    status TEXT DEFAULT 'pending', -- 'pending', 'in_progress', 'completed'
    completed_date TEXT,
    diagnosis TEXT,
    branch_id INTEGER REFERENCES branches(id) ON DELETE SET NULL,
    type TEXT DEFAULT 'vet', -- 'vet', 'vaccine', 'treatment'
    vet_name TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Initial Seed Data
INSERT INTO branches (name) VALUES ('Branch A'), ('Branch B'), ('Branch C') ON CONFLICT DO NOTHING;
INSERT INTO breeds (name) VALUES ('Persian'), ('Siamese'), ('Maine Coon') ON CONFLICT DO NOTHING;
INSERT INTO employees (name, role, username, password) VALUES ('Admin User', 'admin', 'admin', 'admin123') ON CONFLICT DO NOTHING;
INSERT INTO settings (key, value) VALUES ('system_logo', '') ON CONFLICT DO NOTHING;

-- Default Permissions
INSERT INTO role_permissions (role, permissions) VALUES 
('admin', '{"view_dashboard":true,"manage_cats":true,"manage_vaccines":true,"manage_medication":true,"manage_bath":true,"manage_weight":true,"view_employees":true,"manage_employees":true,"manage_settings":true,"manage_breeds":true,"manage_vet":true,"edit_cat_status":true,"export_excel":true,"delete_cat":true,"delete_employee":true}'),
('manager', '{"view_dashboard":true,"manage_cats":true,"manage_vaccines":false,"manage_medication":false,"manage_bath":true,"manage_weight":true,"view_employees":true,"manage_employees":true,"manage_settings":true,"manage_breeds":false,"manage_vet":true,"edit_cat_status":false,"export_excel":false}'),
('supervisor', '{"view_dashboard":true,"manage_cats":true,"manage_vaccines":true,"manage_medication":true,"manage_bath":true,"manage_weight":true,"view_employees":false,"manage_employees":false,"manage_settings":false,"manage_breeds":false,"manage_vet":true,"edit_cat_status":true,"export_excel":false}'),
('staff', '{"view_dashboard":true,"manage_cats":true,"manage_vaccines":false,"manage_medication":false,"manage_bath":true,"manage_weight":true,"view_employees":false,"manage_employees":false,"manage_settings":false,"manage_breeds":false,"manage_vet":true,"edit_cat_status":false,"export_excel":false}')
ON CONFLICT (role) DO UPDATE SET permissions = EXCLUDED.permissions;

-- Function to update cat's lastUpdated timestamp
CREATE OR REPLACE FUNCTION update_cat_last_updated()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE cats SET "lastUpdated" = NOW() WHERE id = NEW.cat_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for various tables
CREATE TRIGGER tr_cat_vaccines_last_updated AFTER INSERT OR UPDATE ON cat_vaccines FOR EACH ROW EXECUTE FUNCTION update_cat_last_updated();
CREATE TRIGGER tr_weight_records_last_updated AFTER INSERT OR UPDATE ON weight_records FOR EACH ROW EXECUTE FUNCTION update_cat_last_updated();
CREATE TRIGGER tr_medication_logs_last_updated AFTER INSERT OR UPDATE ON medication_logs FOR EACH ROW EXECUTE FUNCTION update_cat_last_updated();
CREATE TRIGGER tr_bath_logs_last_updated AFTER INSERT OR UPDATE ON bath_logs FOR EACH ROW EXECUTE FUNCTION update_cat_last_updated();
CREATE TRIGGER tr_care_logs_last_updated AFTER INSERT OR UPDATE ON care_logs FOR EACH ROW EXECUTE FUNCTION update_cat_last_updated();
CREATE TRIGGER tr_vet_visits_last_updated AFTER INSERT OR UPDATE ON vet_visits FOR EACH ROW EXECUTE FUNCTION update_cat_last_updated();
CREATE TRIGGER tr_cat_edit_logs_last_updated AFTER INSERT OR UPDATE ON cat_edit_logs FOR EACH ROW EXECUTE FUNCTION update_cat_last_updated();
