package com.ims185.util;

import java.util.ArrayList;
import java.util.EmptyStackException;
import java.util.List;

public class Stack<T> {
    private List<T> elements;

    public Stack() {
        elements = new ArrayList<>();
    }

    public T push(T item) {
        elements.add(item);
        return item;
    }

    public T pop() {
        if (isEmpty()) {
            throw new EmptyStackException();
        }
        return elements.remove(elements.size() - 1);
    }

    public T peek() {
        if (isEmpty()) {
            throw new EmptyStackException();
        }
        return elements.get(elements.size() - 1);
    }

    public boolean isEmpty() {
        return elements.isEmpty();
    }

    public int size() {
        return elements.size();
    }

    @Override
    public String toString() {
        return elements.toString();
    }

    public boolean contains(T item) {
        return elements.contains(item);
    }

    public List<T> getAll() {
        return new ArrayList<>(elements);
    }

    public boolean moveToTop(T item) {
        // First try to remove it if it exists
        elements.remove(item);
        // Then add it to the top
        elements.add(item);
        return true;
    }
}