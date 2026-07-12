#include <vector>
#include <print>

int main()
{
	std::vector<int> v;
	v.push_back(159);

	std::println("Lenght: {}", v.size());
	std::println("First:  {}", *v.begin());

	return 0;
}
