package com.example.todobackend.service;


import com.example.todobackend.model.Todo;
import com.example.todobackend.repository.TodoRepository; // Assuming you have a TodoRepository
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service; // Crucial: Marks this class as a Spring Service

import java.util.List;
import java.util.Optional;

@Service // This annotation tells Spring that this is a service component
public class TodoService {

    @Autowired // Injects an instance of TodoRepository
    private TodoRepository todoRepository;

    public List<Todo> findAllTodos() {
        return todoRepository.findAll();
    }

    public Optional<Todo> findTodoById(Long id) {
        return todoRepository.findById(id);
    }

    public Todo saveTodo(Todo todo) {
        return todoRepository.save(todo);
    }

    public void deleteTodo(Long id) {
        todoRepository.deleteById(id);
    }

    // You can add more complex business logic here if needed.
    // For example, validation, logging, or interactions with other services.
}
