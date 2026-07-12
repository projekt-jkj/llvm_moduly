#include <filesystem>
#include <print>

int main()
{
    std::println("cwd: {}", std::filesystem::current_path().string());
}