#include <thread>
#include <print>

int main()
{
    std::thread t([]
	{
        std::println("Thread OK");
    });
    t.join();
}