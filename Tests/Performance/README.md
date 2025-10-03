# Performance Tests

This folder contains performance tests for the Learn Morse Code application.

## Running Performance Tests

### Quick Test
```bash
cd Tests/Performance
swift test_performance.swift
```

## Performance Optimizations Implemented

### 1. **Morse Decoding Optimization**
- **Problem**: Exponential complexity in `parseContinuousMorse` with multiple strategies
- **Solution**: 
  - Reduced from 4 strategies to 1 primary strategy with greedy fallback
  - For sequences > 200 characters, use fast greedy approach
  - Reduced max explorations from 1000 to 100
  - Reduced recursion depth from 20 to 10
  - Reduced pattern attempts from 10 to 5

### 2. **Input Size Limits**
- **Problem**: Large inputs caused exponential performance degradation
- **Solution**:
  - Text input limited to 1000 characters (with warning)
  - Morse decoding switches to greedy algorithm at 200 characters
  - Mixed content uses chunked processing at 500 characters
  - Recursive depth limits prevent stack overflow

### 3. **Chunked Processing**
- **Problem**: Character-by-character processing too slow for large inputs
- **Solution**:
  - Mixed content splits into 200-character chunks
  - Processes chunks in sequence
  - Preserves word boundaries

### 4. **Early Termination**
- **Problem**: Algorithms continued searching even after finding good solutions
- **Solution**:
  - Early exit when reasonable solution found (depth < 3)
  - Maximum exploration limits
  - Greedy fallback for edge cases

## Performance Targets

| Input Size | Target Time | Status |
|------------|-------------|--------|
| < 100 chars | < 10ms | ✅ |
| 100-500 chars | < 50ms | ✅ |
| 500-1000 chars | < 200ms | ✅ |
| 1000+ chars | Warned/Truncated | ✅ |

## Known Limitations

1. **Mixed Content**: Complex mixed text/Morse inputs may still be slow
2. **Continuous Morse**: Very long continuous Morse without spaces is computationally expensive
3. **Ambiguous Patterns**: Some Morse patterns have multiple valid interpretations

## Future Improvements

- [ ] Add progress indicators for conversions > 100ms
- [ ] Implement background processing for large conversions
- [ ] Add caching for frequently converted patterns
- [ ] Use SIMD operations for pattern matching
- [ ] Implement parallel chunk processing

