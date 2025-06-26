import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css'; // You can style this later

function App() {
  const [todos, setTodos] = useState([]);
  const [newTodoTitle, setNewTodoTitle] = useState('');
  const [newTodoDescription, setNewTodoDescription] = useState('');
  const API_URL = '/api/todos'; // **IMPORTANT: Change this for deployment**

  useEffect(() => {
    fetchTodos();
  }, []);

  const fetchTodos = async () => {
    try {
      const response = await axios.get(API_URL);
      setTodos(response.data);
    } catch (error) {
      console.error('Error fetching todos:', error);
    }
  };

  const addTodo = async (e) => {
    e.preventDefault();
    if (!newTodoTitle.trim()) return;

    const newTodo = {
      title: newTodoTitle,
      description: newTodoDescription,
      completed: false,
    };

    try {
      await axios.post(API_URL, newTodo);
      setNewTodoTitle('');
      setNewTodoDescription('');
      fetchTodos(); // Refresh the list
    } catch (error) {
      console.error('Error adding todo:', error);
    }
  };

  const toggleComplete = async (id, completed) => {
    try {
      await axios.put(`${API_URL}/${id}`, { completed: !completed });
      fetchTodos(); // Refresh the list
    } catch (error) {
      console.error('Error toggling todo:', error);
    }
  };

  const deleteTodo = async (id) => {
    try {
      await axios.delete(`${API_URL}/${id}`);
      fetchTodos(); // Refresh the list
    } catch (error) {
      console.error('Error deleting todo:', error);
    }
  };

  return (
    <div className="App">
      <h1>Simple To-Do App</h1>

      <form onSubmit={addTodo}>
        <input
          type="text"
          placeholder="Todo Title"
          value={newTodoTitle}
          onChange={(e) => setNewTodoTitle(e.target.value)}
        />
        <input
          type="text"
          placeholder="Todo Description (optional)"
          value={newTodoDescription}
          onChange={(e) => setNewTodoDescription(e.target.value)}
        />
        <button type="submit">Add Todo</button>
      </form>

      <ul className="todo-list">
        {todos.map((todo) => (
          <li key={todo.id} className={todo.completed ? 'completed' : ''}>
            <span
              onClick={() => toggleComplete(todo.id, todo.completed)}
              style={{ cursor: 'pointer' }}
            >
              <strong>{todo.title}</strong>
              {todo.description && `: ${todo.description}`}
            </span>
            <button onClick={() => deleteTodo(todo.id)}>Delete</button>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default App;