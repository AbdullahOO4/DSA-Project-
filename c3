class LogStack {
    struct SNode {
        string action;
        SNode* next = nullptr;
    };
    SNode* top = nullptr;

public:
    // Push log entry onto stack and persist to file
    void push(const string& action) {
        SNode* n  = new SNode;
        n->action = action;
        n->next   = top;   // O(1) LIFO insert
        top       = n;
        lock_guard<mutex> lock(fileMutex);
        ofstream f("data/log.txt", ios::app);
        f << "[" << getTimestamp() << "] "
          << action << "\n";
    }

   
    string toJSON() {
        string out = "[";
        SNode* t = top;
        bool first = true;
        while (t) {
            if (!first) out += ",";
            out += """ + jsonEsc(t->action) + """;
            first = false;
            t = t->next;
        }
        return out + "]";
    }
};
LogStack logs;   // global instance


class RequestQueue {
    RequestNode* front = nullptr;
    RequestNode* rear  = nullptr;

public:
    void enqueue(Request r) {
        RequestNode* n = new RequestNode;
        n->data = r;
        if (!rear) {
            front = rear = n;  // first element
        } else {
            rear->next = n;    // append to tail
            rear       = n;
        }
    }
    RequestNode* getFront() { return front; }
};
