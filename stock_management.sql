-- Clean up old triggers/functions
DROP TRIGGER IF EXISTS tr_deduct_stock_on_order_item ON public.order_items;
DROP TRIGGER IF EXISTS tr_restore_stock_on_item_delete ON public.order_items;
DROP TRIGGER IF EXISTS tr_order_status_stock_change ON public.orders;
DROP TRIGGER IF EXISTS tr_stock_on_item_insert ON public.order_items;

-- Helper function to adjust stock for a specific order
CREATE OR REPLACE FUNCTION adjust_stock_for_order(order_id_param UUID, multiplier INTEGER)
RETURNS VOID AS $$
DECLARE
    item RECORD;
BEGIN
    FOR item IN SELECT variant_id, quantity FROM public.order_items WHERE order_id = order_id_param LOOP
        UPDATE public.variants
        SET stock_quantity = stock_quantity + (item.quantity * multiplier)
        WHERE id = item.variant_id;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- 1. Trigger for STATUS CHANGES on existing orders
CREATE OR REPLACE FUNCTION handle_order_status_stock_change()
RETURNS TRIGGER AS $$
BEGIN
    -- Transition: Pending -> Packing (Accepted)
    -- This is the "Accept" action.
    IF (OLD.status = 'pending' AND NEW.status = 'packing') THEN
        PERFORM adjust_stock_for_order(NEW.id, -1);
    END IF;

    -- Transition: Active -> Cancelled
    -- Restore stock if the order was already accepted.
    IF (OLD.status != 'pending' AND OLD.status != 'cancelled' AND NEW.status = 'cancelled') THEN
        PERFORM adjust_stock_for_order(NEW.id, 1);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_order_status_stock_change
AFTER UPDATE ON public.orders
FOR EACH ROW
EXECUTE FUNCTION handle_order_status_stock_change();

-- 2. Trigger for NEW ITEMS being added to an already accepted/packing order
CREATE OR REPLACE FUNCTION handle_order_item_stock()
RETURNS TRIGGER AS $$
DECLARE
    v_order_status TEXT;
BEGIN
    -- Get current status of the order
    SELECT status INTO v_order_status FROM public.orders WHERE id = NEW.order_id;

    -- If the order is NOT pending (e.g. was created as 'packing' or already accepted)
    -- we deduct stock as soon as the item is added.
    IF (v_order_status != 'pending' AND v_order_status != 'cancelled') THEN
        UPDATE public.variants
        SET stock_quantity = stock_quantity - NEW.quantity
        WHERE id = NEW.variant_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_stock_on_item_insert
AFTER INSERT ON public.order_items
FOR EACH ROW
EXECUTE FUNCTION handle_order_item_stock();

-- 3. Trigger for DELETING items (Restoration)
CREATE OR REPLACE FUNCTION handle_order_item_delete_stock()
RETURNS TRIGGER AS $$
DECLARE
    v_order_status TEXT;
BEGIN
    SELECT status INTO v_order_status FROM public.orders WHERE id = OLD.order_id;

    -- Restore stock if the item was part of an active (non-pending) order
    IF (v_order_status != 'pending' AND v_order_status != 'cancelled') THEN
        UPDATE public.variants
        SET stock_quantity = stock_quantity + OLD.quantity
        WHERE id = OLD.variant_id;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_stock_on_item_delete
AFTER DELETE ON public.order_items
FOR EACH ROW
EXECUTE FUNCTION handle_order_item_delete_stock();
