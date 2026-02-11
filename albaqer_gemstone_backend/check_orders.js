const pool = require('./db/connection');

pool.query(`
  SELECT id, order_number, status, delivery_man_id, user_id 
  FROM orders 
  WHERE status IN ('assigned', 'in_transit') 
  ORDER BY id DESC LIMIT 5
`).then(r => {
  console.log('Recent delivery orders:');
  r.rows.forEach(o => {
    console.log(`  Order #${o.id} (${o.order_number}) - Status: ${o.status}, Delivery: ${o.delivery_man_id}, Customer: ${o.user_id}`);
  });
  
  pool.query(`
    SELECT oi.order_id, COUNT(*) as item_count
    FROM order_items oi
    WHERE oi.order_id IN (${r.rows.map(o => o.id).join(',')})
    GROUP BY oi.order_id
  `).then(r2 => {
    console.log('\nOrder items count:');
    r2.rows.forEach(o => {
      console.log(`  Order #${o.order_id}: ${o.item_count} items`);
    });
    process.exit(0);
  });
});
