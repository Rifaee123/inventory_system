-- Enable RLS for order_items if not already enabled
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Policy to allow public to insert order_items (temporary for development)
CREATE POLICY "Allow public insert order_items" 
ON order_items FOR INSERT 
TO public 
WITH CHECK (true);

-- Policy to allow public to view order_items
CREATE POLICY "Allow public select order_items" 
ON order_items FOR SELECT 
TO public 
USING (true);

-- Policy to allow public to update order_items
CREATE POLICY "Allow public update order_items" 
ON order_items FOR UPDATE 
TO public 
USING (true)
WITH CHECK (true);

-- Policy to allow public to delete order_items
CREATE POLICY "Allow public delete order_items" 
ON order_items FOR DELETE 
TO public 
USING (true);
