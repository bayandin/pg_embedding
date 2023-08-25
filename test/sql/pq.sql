CREATE TABLE t (id integer primary key, val real[]);
select setseed(0.5);
INSERT INTO t select id, array[random(), random(), random(), random()] from generate_series(1,10000) id;
CREATE INDEX hnsw_pq_idx ON t USING hnsw (val) WITH (dims=4, m=8, efConstruction=16, efSearch=10, pqBits=3, pqSubqs=2);
CREATE INDEX ON t USING hnsw (val) WITH (dims=4, m=8, efConstruction=16, efSearch=10);

SET enable_seqscan = off;
explain SELECT * FROM t ORDER BY val <-> array[0.5,0.5,0.5,0.5] limit 10;
SELECT * FROM t ORDER BY val <-> array[0.5,0.5,0.5,0.5] limit 10;

SET enable_seqscan = on;
SET enable_indexscan = off;
explain SELECT * FROM t ORDER BY val <-> array[0.5,0.5,0.5,0.5] limit 10;
SELECT * FROM t ORDER BY val <-> array[0.5,0.5,0.5,0.5] limit 10;
select pg_relation_size('hnsw_pq_idx');

drop index hnsw_pq_idx;
CREATE INDEX hnsw_idx ON t USING hnsw (val) WITH (dims=4, m=8, efConstruction=16, efSearch=10);
SELECT * FROM t ORDER BY val <-> array[0.5,0.5,0.5,0.5] limit 10;
select pg_relation_size('hnsw_idx');

DROP TABLE t;
