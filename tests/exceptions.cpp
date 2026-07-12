#include <stdexcept>
#include <print>

int main()
{
    try
	{
        throw std::runtime_error("OK");
    }
	catch (const std::exception& e)
	{
        std::println("Caught: {}", e.what());
    }
}