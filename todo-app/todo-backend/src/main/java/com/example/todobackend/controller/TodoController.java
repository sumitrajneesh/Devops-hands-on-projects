package com.example.todobackend.controller;

import com.example.todobackend.model.Todo;
import com.example.todobackend.service.TodoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController // Crucial: Marks this class as a REST controller
@RequestMapping("/api/todos") // Crucial: Base path for all endpoints in this controller
@CrossOrigin(origins = "http://localhost:8081", methods = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT, RequestMethod.DELETE, RequestMethod.OPTIONS}, allowCredentials = "true") // Example CORS if not handled by properties
public class TodoController {

    @Autowired
    private TodoService todoService;

    @GetMapping // Maps GET requests to /api/todos
    public List<Todo> getAllTodos() {
        return todoService.findAllTodos();
    }

    @GetMapping("/{id}") // Maps GET requests to /api/todos/{id}
    public ResponseEntity<Todo> getTodoById(@PathVariable Long id) {
        Optional<Todo> todo = todoService.findTodoById(id);
        return todo.map(ResponseEntity::ok)
                   .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PostMapping // Maps POST requests to /api/todos
    public ResponseEntity<Todo> createTodo(@RequestBody Todo todo) {
        Todo savedTodo = todoService.saveTodo(todo);
        return new ResponseEntity<>(savedTodo, HttpStatus.CREATED);
    }

    @PutMapping("/{id}") // Maps PUT requests to /api/todos/{id}
    public ResponseEntity<Todo> updateTodo(@PathVariable Long id, @RequestBody Todo todo) {
        if (!todoService.findTodoById(id).isPresent()) {
            return ResponseEntity.notFound().build();
        }
        todo.setId(id); // Ensure ID from path is set on the object
        Todo updatedTodo = todoService.saveTodo(todo);
        return ResponseEntity.ok(updatedTodo);
    }

    @DeleteMapping("/{id}") // Maps DELETE requests to /api/todos/{id}
    public ResponseEntity<Void> deleteTodo(@PathVariable Long id) {
        if (!todoService.findTodoById(id).isPresent()) {
            return ResponseEntity.notFound().build();
        }
        todoService.deleteTodo(id);
        return ResponseEntity.noContent().build();
    }
}