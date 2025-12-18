```mermaid
flowchart TB
    subgraph Client
        A[Call Taker UI]
    end

    subgraph Kubernetes_Cluster["Kubernetes Cluster"]
        B[Load Balancer]

        subgraph API_Layer["API Layer"]
            C[API<br>WebSocket Gateway]
        end

        subgraph Model_Serving_Layer["Model Serving"]
            D[Triton / TorchServe<br>Pre-optimized model]
        end
    end

    A -->|Streaming Audio| B
    B --> C
    C -->|Audio Chunks| D
    D -->|Partial and Final Transcript| C
    C -->|Real-time Transcript| B
    B --> A
```
