const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const Database = require('better-sqlite3');

const JWT_SECRET = process.env.JWT_SECRET || 'wifi_cards_secret_2026';
const PORT = process.env.PORT || 3000;
const db = new Database('wifi.db');

db.pragma('journal_mode = WAL');

db.exec(`
  CREATE TABLE IF NOT EXISTS users(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    account_no TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    password TEXT NOT NULL,
    role TEXT DEFAULT 'agent',
    balance REAL DEFAULT 0,
    commission REAL DEFAULT 0
  );
  CREATE TABLE IF NOT EXISTS networks(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    number TEXT, name TEXT, phone1 TEXT, phone2 TEXT, owner_id INTEGER
  );
  CREATE TABLE IF NOT EXISTS favorites(
    user_id INTEGER, network_id INTEGER, PRIMARY KEY(user_id,network_id)
  );
  CREATE TABLE IF NOT EXISTS categories(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    network_id INTEGER, title TEXT, price REAL,
    commission REAL DEFAULT 0, duration_hours INTEGER DEFAULT 24
  );
  CREATE TABLE IF NOT EXISTS cards(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_id INTEGER, code TEXT UNIQUE,
    status TEXT DEFAULT 'available',
    sold_at TEXT, sale_price REAL DEFAULT 0, commission REAL DEFAULT 0
  );
  CREATE TABLE IF NOT EXISTS sales(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    card_id INTEGER, agent_id INTEGER, category_id INTEGER, network_id INTEGER,
    price REAL, commission REAL, created_at TEXT DEFAULT (datetime('now','localtime'))
  );
  CREATE TABLE IF NOT EXISTS transactions(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER, type TEXT, amount REAL, note TEXT,
    created_at TEXT DEFAULT (datetime('now','localtime'))
  );
`);

if (db.prepare('SELECT COUNT(*) c FROM users').get().c === 0) {
  const hash = bcrypt.hashSync('123456', 10);

  const userInsert = db
    .prepare('INSERT INTO users(account_no,name,password) VALUES(?,?,?)')
    .run('121729', 'سمير عبده قائد احمد', hash);

  const agentId = userInsert.lastInsertRowid;

  const addNet = db.prepare(
    'INSERT INTO networks(number,name,phone1,phone2,owner_id) VALUES(?,?,?,?,?)'
  );

  const networkId = addNet
    .run('1164', 'شبكة التبوكي نت ( تعز - الاقروض )', '734617188', '730728514', agentId)
    .lastInsertRowid;

  addNet.run('1', 'البرق نت (تعز-صبر التحرير الموشكي )', '', '', agentId);
  addNet.run('4', 'صبر واي فاي (تعز )', '', '', agentId);

  const addCat = db.prepare(
    'INSERT INTO categories(network_id,title,price,commission) VALUES(?,?,?,?)'
  );

  const catData = [
    [200, 20, 44],
    [500, 50, 29],
    [1000, 100, 3],
    [2000, 200, 3],
  ];

  const insertCard = db.prepare(
    'INSERT INTO cards(category_id,code) VALUES(?,?)'
  );

  const sellCard = db.prepare(`
    UPDATE cards SET status='sold', sold_at=datetime('now','localtime'),
    sale_price=?, commission=? WHERE id=?
  `);

  catData.forEach(([price, com, sold]) => {
    const categoryId = addCat.run(networkId, 'فئة ' + price, price, com).lastInsertRowid;

    for (let index = 1; index <= 150; index++) {
      const cardId = insertCard.run(categoryId, categoryId + '-' + (100000 + index))
        .lastInsertRowid;

      if (index <= sold) {
        sellCard.run(price, com, cardId);
      }
    }
  });

  console.log('تم إنشاء البيانات الأولية');
}

function auth(req, res, next) {
  const token = (req.headers.authorization || '').replace('Bearer ', '');

  try {
    req.user = jwt.verify(token, JWT_SECRET);
    next();
  } catch (_) {
    res.status(401).json({ error: 'يجب تسجيل الدخول' });
  }
}

const app = express();
app.use(cors());
app.use(express.json({ limit: '5mb' }));

app.post('/api/login', (req, res) => {
  const { account_no, password } = req.body;

  const user = db.prepare('SELECT * FROM users WHERE account_no=?').get(account_no);

  if (!user || !bcrypt.compareSync(password || '', user.password)) {
    return res.status(400).json({
      error: 'رقم الحساب أو كلمة المرور غير صحيحة',
    });
  }

  const token = jwt.sign(
    {
      id: user.id,
      account_no: user.account_no,
      name: user.name,
    },
    JWT_SECRET,
    { expiresIn: '30d' }
  );

  res.json({
    token,
    user: {
      id: user.id,
      account_no: user.account_no,
      name: user.name,
      balance: user.balance,
      commission: user.commission,
    },
  });
});

app.get('/api/me', auth, (req, res) => {
  res.json(
    db
      .prepare('SELECT id,account_no,name,balance,commission FROM users WHERE id=?')
      .get(req.user.id)
  );
});

app.get('/api/networks', auth, (req, res) => {
  const { search = '', fav = '0' } = req.query;

  let q = `
    SELECT n.*, CASE WHEN f.network_id IS NULL THEN 0 ELSE 1 END is_favorite
    FROM networks n
    LEFT JOIN favorites f ON f.network_id=n.id AND f.user_id=?
    WHERE (n.name LIKE ? OR n.number LIKE ? OR n.phone1 LIKE ?)
  `;

  const params = [req.user.id, `%${search}%`, `%${search}%`, `%${search}%`];

  if (fav === '1') {
    q += ' AND f.network_id IS NOT NULL';
  }

  q += ' ORDER BY n.id';

  res.json(db.prepare(q).all(...params));
});

app.post('/api/networks/:id/fav', auth, (req, res) => {
  const networkId = Number(req.params.id);

  const existing = db
    .prepare('SELECT 1 x FROM favorites WHERE user_id=? AND network_id=?')
    .get(req.user.id, networkId);

  if (existing) {
    db.prepare('DELETE FROM favorites WHERE user_id=? AND network_id=?').run(
      req.user.id,
      networkId
    );
  } else {
    db.prepare('INSERT INTO favorites(user_id,network_id) VALUES(?,?)').run(
      req.user.id,
      networkId
    );
  }

  res.json({ ok: true, favorite: !existing });
});

app.get('/api/my-networks', auth, (req, res) => {
  res.json(
    db.prepare('SELECT * FROM networks WHERE owner_id=? ORDER BY id').all(req.user.id)
  );
});

app.get('/api/networks/:id/categories', auth, (req, res) => {
  res.json(
    db.prepare(`
      SELECT c.*,
        (SELECT COUNT(*) FROM cards WHERE category_id=c.id AND status='available') remaining,
        (SELECT COUNT(*) FROM cards WHERE category_id=c.id AND status='sold') sold
      FROM categories c
      WHERE c.network_id=?
      ORDER BY c.price
    `).all(Number(req.params.id))
  );
});

app.post('/api/categories', auth, (req, res) => {
  const { network_id, title, price, commission = 0, duration_hours = 24 } = req.body;

  const result = db
    .prepare(
      'INSERT INTO categories(network_id,title,price,commission,duration_hours) VALUES(?,?,?,?,?)'
    )
    .run(network_id, title, price, commission, duration_hours);

  res.json({ id: result.lastInsertRowid });
});

app.post('/api/categories/:id/cards', auth, (req, res) => {
  const categoryId = Number(req.params.id);
  let { codes = [], count = 0 } = req.body;

  if (!codes.length && count > 0) {
    codes = Array.from({ length: count }, () => {
      return categoryId + '-' + Math.random().toString(36).slice(2, 8).toUpperCase();
    });
  }

  const insert = db.prepare(
    'INSERT OR IGNORE INTO cards(category_id,code) VALUES(?,?)'
  );

  let added = 0;

  db.transaction(() => {
    codes.forEach((code) => {
      added += insert.run(categoryId, String(code).trim()).changes;
    });
  })();

  res.json({ added });
});

app.get('/api/categories/:id/cards', auth, (req, res) => {
  const { status = '' } = req.query;
  let q = 'SELECT * FROM cards WHERE category_id=?';
  const params = [Number(req.params.id)];

  if (status) {
    q += ' AND status=?';
    params.push(status);
  }

  q += ' ORDER BY id DESC LIMIT 500';

  res.json(db.prepare(q).all(...params));
});

app.get('/api/networks/:id/cards', auth, (req, res) => {
  const { status = '' } = req.query;
  let q = `
    SELECT cd.*, c.title cat_title, c.price
    FROM cards cd
    JOIN categories c ON c.id=cd.category_id
    WHERE c.network_id=?
  `;
  const params = [Number(req.params.id)];

  if (status) {
    q += ' AND cd.status=?';
    params.push(status);
  }

  q += ' ORDER BY cd.id DESC LIMIT 1000';

  res.json(db.prepare(q).all(...params));
});

app.post('/api/cards/:id/sell', auth, (req, res) => {
  const card = db.prepare('SELECT * FROM cards WHERE id=?').get(Number(req.params.id));

  if (!card) {
    return res.status(404).json({ error: 'الكرت غير موجود' });
  }

  if (card.status !== 'available') {
    return res.status(400).json({ error: 'الكرت غير متاح للبيع' });
  }

  const category = db
    .prepare('SELECT * FROM categories WHERE id=?')
    .get(card.category_id);

  db.transaction(() => {
    db.prepare(`
      UPDATE cards SET status='sold', sold_at=datetime('now','localtime'),
      sale_price=?, commission=? WHERE id=?
    `).run(category.price, category.commission, card.id);

    db.prepare(
      'INSERT INTO sales(card_id,agent_id,category_id,network_id,price,commission) VALUES(?,?,?,?,?,?)'
    ).run(
      card.id,
      req.user.id,
      category.id,
      category.network_id,
      category.price,
      category.commission
    );

    db.prepare(
      'UPDATE users SET commission=commission+?, balance=balance+? WHERE id=?'
    ).run(category.commission, category.commission, req.user.id);

    db.prepare(
      'INSERT INTO transactions(user_id,type,amount,note) VALUES(?,?,?,?)'
    ).run(req.user.id, 'commission', category.commission, 'عمولة بيع كرت ' + card.code);

    db.prepare(
      'INSERT INTO transactions(user_id,type,amount,note) VALUES(?,?,?,?)'
    ).run(req.user.id, 'sale', category.price, 'بيع كرت ' + card.code);
  })();

  res.json({ ok: true, commission: category.commission });
});

app.get('/api/sales', auth, (req, res) => {
  const { network_id = '' } = req.query;

  let q = `
    SELECT s.*, c.code, cat.title cat_title
    FROM sales s
    JOIN cards c ON c.id=s.card_id
    JOIN categories cat ON cat.id=s.category_id
    WHERE s.agent_id=?
  `;

  const params = [req.user.id];

  if (network_id) {
    q += ' AND s.network_id=?';
    params.push(Number(network_id));
  }

  q += ' ORDER BY s.id DESC LIMIT 500';

  res.json(db.prepare(q).all(...params));
});

app.get('/api/transactions', auth, (req, res) => {
  res.json(
    db.prepare('SELECT * FROM transactions WHERE user_id=? ORDER BY id DESC LIMIT 500').all(req.user.id)
  );
});

app.post('/api/topup', auth, (req, res) => {
  const amount = Number(req.body.amount) || 0;
  db.prepare('UPDATE users SET balance=balance+? WHERE id=?').run(amount, req.user.id);
  db.prepare(
    'INSERT INTO transactions(user_id,type,amount,note) VALUES(?,?,?,?)'
  ).run(req.user.id, 'topup', amount, 'تغذية حساب');

  res.json({ ok: true });
});

app.listen(PORT, () => {
  console.log('API يعمل على المنفذ ' + PORT);
});
