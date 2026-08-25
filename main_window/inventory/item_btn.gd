extends DefaultBtn

@onready var content_container: MarginContainer = $ContentContainer
@onready var texture: TextureRect = %Texture
@onready var price_label: Label = %PriceLabel
@onready var amount_label: Label = %AmountLabel

var item : Item
var shop := true
var local_price : int

func _ready() -> void:
	if item == null:
		queue_free()
		return
	super()
	local_price = InventoryManager.get_local_price(item)
	_update_disabled()
	_update_content()
	_add_tooltip()

func _update_disabled():
	await get_tree().physics_frame
	if shop and local_price > AttributesManager.gold:
		disabled = true
	if disabled:
		content_container.modulate = Color("819796")

func _update_content():
	if item.icon && item.icon is Texture2D:
		texture.texture = item.icon
	amount_label.text = "%s" % ("x%s" % item.amount if not shop else "")
	price_label.text = "%s G" % local_price

func _add_tooltip():
	tooltip = item.title
	tooltip += "\nLocal price: %s" % local_price

func _on_pressed() -> void:
	var trade_amount = InventoryManager.trade_amount
	if shop:
		var affordable_amount : int = min(
			trade_amount,
			floori(AttributesManager.gold / float(local_price))
		)
		var remaining_weight := InventoryManager.MAX_WEIGHT - InventoryManager.current_weight
		var carriable_amount: int = min(
			trade_amount,
			floori(remaining_weight / float(item.weight))
		)
		var actual_amount: int = min(
			affordable_amount,
			carriable_amount
		)
		if actual_amount <= 0: return
		InventoryManager.set_inventory(item, actual_amount)
		AttributesManager.gold -= local_price * actual_amount
	else:
		var inventory_item: Item = InventoryManager.inventory.get(item.id)
		if inventory_item == null: return
		var actual_amount : int = min(
			trade_amount,
			inventory_item.amount
		)
		InventoryManager.set_inventory(item, actual_amount * -1)
		AttributesManager.gold += local_price * actual_amount
