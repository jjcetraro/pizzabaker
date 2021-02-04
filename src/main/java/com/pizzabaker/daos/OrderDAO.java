package com.pizzabaker.daos;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import com.pizzabaker.entities.BasePizza;
import com.pizzabaker.entities.IngredientDetail;
import com.pizzabaker.entities.Order;
import com.pizzabaker.entities.OrderIngredient;

public class OrderDAO {

	//--------------------------------------------------------------------------------------------------
	//--------------------------------------------------------------------------------------------------
	//----------------------------------------- PUBLIC METHODS -----------------------------------------
	//--------------------------------------------------------------------------------------------------
	//--------------------------------------------------------------------------------------------------

	public List<Order> selectOrders() throws DBConnectionException{
		Connection connection = null;
		try {
			connection = DBConnection.GetConnection();
			Map<Long, Order> mapOrderById = getMapOrdersById_lazy(connection, null);
			Map<Long, List<OrderIngredient>> mapOrderIngredientsByOrderId = getMapOrderIngredientsByOrderId(connection, null);
			List<Order> ret = new ArrayList<>();
			for(Entry<Long, Order> entry : mapOrderById.entrySet()) {
				Order order = entry.getValue();
				order.setIngredients(mapOrderIngredientsByOrderId.get(order.getId()));
				ret.add(order);
			}
			return ret;
		} catch (SQLException e) {
			try {
				connection.close();
			}catch(Exception ex) {}
			throw new DBConnectionException("There was an error getting the orders from the database", e);
		}
	}
	
	public void insertOrder(Order order) throws DBConnectionException {
		Connection connection = null;
		try {
			connection = DBConnection.GetConnection();
			CallableStatement callableStatement = connection.prepareCall("{ ? = call ins_order(?, ?, ?) }");
			callableStatement.registerOutParameter(1, Types.BIGINT);
			callableStatement.setDate(2, new java.sql.Date(order.getDatetime().getTime()));
			callableStatement.setLong(3, order.getBasePizza().getId());
			callableStatement.setDouble(4, order.getBasePizza().getPrice());
			callableStatement.execute();
			long id = callableStatement.getLong(1);
			callableStatement.close();
			
			// insert the order lines
			callableStatement = connection.prepareCall("{ ? = call ins_order_ingredient_detail(?, ?, ?, ?) }");
			for(OrderIngredient ing : order.getIngredients()) {
				callableStatement.registerOutParameter(1, Types.BIGINT);
				callableStatement.setLong(2, id);
				callableStatement.setLong(3, ing.getIngredientDetail().getId());
				callableStatement.setInt(4, ing.getQuantity());
				callableStatement.setDouble(5, ing.getPrice());
				callableStatement.execute();
			}
			callableStatement.close();
			connection.close();
		} catch (SQLException e) {
			try {
				connection.close();
			}catch(Exception ex) {}
			throw new DBConnectionException("There was an error trying to add the order", e);
		}
	}
	
	
	//--------------------------------------------------------------------------------------------------
	//--------------------------------------------------------------------------------------------------
	//---------------------------------------- PRIVATE METHODS  ----------------------------------------
	//--------------------------------------------------------------------------------------------------
	//--------------------------------------------------------------------------------------------------
	
	private Map<Long, Order> getMapOrdersById_lazy(Connection connection, String condition) throws SQLException{
		Map<Long, BasePizza> mapBasePizzaById = null;
		try{
			mapBasePizzaById = new BasePizzaDAO().getMapBasePizzasById();
		}catch(Exception ex) {
			throw new SQLException(ex);
		}
		String query = "SELECT * FROM \"order\"";
		if(condition != null && !condition.trim().isEmpty()) {
			query += " WHERE " + condition;
		}
		PreparedStatement ps = connection.prepareStatement(query);
		ResultSet rs = ps.executeQuery();
		Map<Long, Order> ret = new HashMap<>();
		while(rs.next()) {
			long id = rs.getLong("id");
			Date datetime = rs.getDate("datetime");
			long idPizza = rs.getLong("id_pizza");
			BasePizza basePizza = new BasePizza(mapBasePizzaById.get(idPizza));
			Order order = new Order(id, datetime, basePizza, null);
			ret.put(id, order);
		}
		rs.close();
		ps.close();
		return ret;
	}
	
	private Map<Long, List<OrderIngredient>> getMapOrderIngredientsByOrderId(Connection connection, String condition) throws SQLException{
		Map<Long, IngredientDetail> mapIngredientDetailById = new IngredientDAO().getMapIngredientDetailById(connection, null);
		Map<Long, String> mapIngredientNameByDetailId = new IngredientDAO().getMapIngredientNameByIngredientDetailId(connection, condition);
		Map<Long, List<OrderIngredient>> ret = new HashMap<>();
		String query = "SELECT * FROM order_ingredient_detail";
		if(condition != null && !condition.trim().isEmpty()) {
			query += " WHERE " + condition;
		}
		PreparedStatement ps = connection.prepareStatement(query);
		ResultSet rs = ps.executeQuery();
		while(rs.next()) {
			long idOrder = rs.getLong("id_order");
			long idIngredientDetail = rs.getLong("id_ingredient_detail");
			IngredientDetail ingredientDetail = new IngredientDetail(mapIngredientDetailById.get(idIngredientDetail));
			int quantity = rs.getInt("quantity");
			double price = rs.getDouble("price");
			OrderIngredient orderIngredient = new OrderIngredient(mapIngredientNameByDetailId.get(idIngredientDetail), ingredientDetail, quantity, price);
			if(!ret.containsKey(idOrder)) {
				ret.put(idOrder, new ArrayList<>());
			}
			ret.get(idOrder).add(orderIngredient);
		}
		rs.close();
		ps.close();
		return ret;
	}
}
