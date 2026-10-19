// PostgreSQL local con metadatos auditados; nunca importa filas de producción.
import { readFile } from 'node:fs/promises';
export const evidence = JSON.parse(await readFile(new URL('../../diagnostico/2026-10-19/evidencia_supabase.json', import.meta.url),'utf8'));
const schema = JSON.parse(await readFile(new URL('./schema-auditado.json', import.meta.url),'utf8'));
const ident = s => '"'+s.replaceAll('"','""')+'"';
export async function loadBaseline(db) {
  // auth.uid devuelve UUID; la conversión explícita reproduce el contrato de Supabase.
  await db.exec(`CREATE ROLE anon NOLOGIN; CREATE ROLE authenticated NOLOGIN; CREATE ROLE service_role NOLOGIN BYPASSRLS;
    CREATE SCHEMA auth; CREATE SCHEMA storage;
    CREATE TABLE auth.users(id uuid PRIMARY KEY,email text,created_at timestamptz DEFAULT now(),last_sign_in_at timestamptz,email_confirmed_at timestamptz);
    CREATE FUNCTION auth.uid() RETURNS uuid LANGUAGE sql STABLE AS $$ SELECT (nullif(current_setting('request.jwt.claims',true),'')::jsonb->>'sub')::uuid $$;
    CREATE FUNCTION auth.role() RETURNS text LANGUAGE sql STABLE AS $$ SELECT nullif(current_setting('request.jwt.claims',true),'')::jsonb->>'role' $$;
    GRANT USAGE ON SCHEMA auth,storage,public TO anon,authenticated;
    CREATE TABLE storage.buckets(id text PRIMARY KEY,name text,public boolean,file_size_limit bigint,allowed_mime_types text[]);
    CREATE TABLE storage.objects(id uuid PRIMARY KEY DEFAULT gen_random_uuid(),bucket_id text REFERENCES storage.buckets(id),name text NOT NULL,owner_id text,metadata jsonb,created_at timestamptz DEFAULT now(),UNIQUE(bucket_id,name));
    ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;
    INSERT INTO storage.buckets(id,name,public) VALUES('relevamientos','relevamientos',true),('fotos-relevamiento','fotos-relevamiento',true);
  `);
  for (const t of schema.tables) {
    for(const c of t.columns) {
      const seq = c.default_value?.match(/nextval\('([^']+)'/);
      if(seq) await db.exec(`CREATE SEQUENCE IF NOT EXISTS public.${ident(seq[1])}`);
    }
    const cols=t.columns.map(c=> {
      let sql=`${ident(c.name)} ${c.data_type==='ARRAY' ? c.format.slice(1)+'[]' : c.format}`;
      if(c.options.includes('generated')) sql+=` GENERATED ALWAYS AS (${c.default_value}) STORED`;
      else if(c.default_value) sql+=` DEFAULT ${c.default_value}`;
      if(!c.options.includes('nullable')) sql+=' NOT NULL';
      if(c.check) sql+=` CHECK (${c.check})`;
      return sql;
    });
    if(t.primary_keys.length) cols.push(`PRIMARY KEY (${t.primary_keys.map(ident).join(',')})`);
    await db.exec(`CREATE TABLE ${t.name} (${cols.join(',')}); ALTER TABLE ${t.name} ENABLE ROW LEVEL SECURITY;`);
  }
  const seen=new Set();
  for(const t of schema.tables) for(const f of t.foreign_key_constraints??[]) {
    if(seen.has(f.name))continue; seen.add(f.name);
    await db.exec(`ALTER TABLE ${f.source_table} ADD CONSTRAINT ${ident(f.name)} FOREIGN KEY (${f.source_columns.map(ident)}) REFERENCES ${f.target_table} (${f.target_columns.map(ident)})`);
  }
  // SQL helpers can reference functions defined later; validated after all exist.
  await db.exec('SET check_function_bodies=off');
  for(const f of evidence.functions) await db.exec(f.definition);
  await db.exec('SET check_function_bodies=on');
  for(const f of evidence.functions) {
    await db.exec(`REVOKE ALL ON FUNCTION public.${ident(f.proname)}(${f.args}) FROM PUBLIC,anon,authenticated`);
    if(f.anon_execute) await db.exec(`GRANT EXECUTE ON FUNCTION public.${ident(f.proname)}(${f.args}) TO anon`);
    if(f.auth_execute) await db.exec(`GRANT EXECUTE ON FUNCTION public.${ident(f.proname)}(${f.args}) TO authenticated`);
  }
  for(const p of evidence.policies) {
    let sql=`CREATE POLICY ${ident(p.policyname)} ON ${p.schemaname}.${ident(p.tablename)} AS ${p.permissive} FOR ${p.cmd} TO ${p.roles.slice(1,-1)}`;
    if(p.qual) sql+=` USING (${p.qual.replaceAll('\\n','\n')})`;
    if(p.with_check) sql+=` WITH CHECK (${p.with_check.replaceAll('\\n','\n')})`;
    await db.exec(sql);
  }
  for(const t of evidence.metadata[0].diagnostico.triggers) await db.exec(t.definition);
  await db.exec(`GRANT ALL ON ALL TABLES IN SCHEMA public,storage TO anon,authenticated;
    GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon,authenticated;`);
}
