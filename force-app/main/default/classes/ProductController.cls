/**
 * @description       : 
 * @author            : yeonji.lim@dkbmc.com
 * @group             : 
 * @last modified on  : 07-25-2023
 * @last modified by  : yeonji.lim@dkbmc.com
**/
public with sharing class ProductController {
    // 상수: 페이지 당 표시되는 제품 수
    static Integer PAGE_SIZE = 9;

    //내부 클래스 
    public class Filters {
        @AuraEnabled
        public String searchKey { get; set; }
        @AuraEnabled
        public Decimal maxPrice { get; set; }
        @AuraEnabled
        public String[] categories { get; set; }
        @AuraEnabled
        public String[] materials { get; set; }
        @AuraEnabled
        public String[] levels { get; set; }
    }

    //product를 필터링하여 페이지별로 반환 
    @AuraEnabled(Cacheable=true scope='global')
    public static PagedResult getProducts(Filters filters, Integer pageNumber) {
        // key : 검색어 필터에 사용되는 문자열, whereClause : SOQL 쿼리에서 WHERE 절에 사용되는 문자열
        String key, whereClause = '';
        
        // 최대가격을 담는 변수
        Decimal maxPrice;
        
        // 필터 정보를 담는 배열 변수
        // criteria : 쿼리 조건들을 담음
        String[] categories, materials, levels, criteria = new List<String>{};
        
        if (filters != null) {
            maxPrice = filters.maxPrice;
            materials = filters.materials;
            levels = filters.levels;

            if (!String.isEmpty(filters.searchKey)) {
                key = '%' + filters.searchKey + '%';
                criteria.add('Name LIKE :key');
            }
            if (filters.maxPrice >= 0) {
                maxPrice = filters.maxPrice;
                criteria.add('MSRP__c <= :maxPrice');
            }
            if (filters.categories != null) {
                categories = filters.categories;
                criteria.add('Category__c IN :categories');
            }
            if (filters.levels != null) {
                levels = filters.levels;
                criteria.add('Level__c IN :levels');
            }
            if (filters.materials != null) {
                materials = filters.materials;
                criteria.add('Material__c IN :materials');
            }
            
            //criteria 조건이 있을 경우 
            if (criteria.size() > 0) {
                whereClause = 'WHERE ' + String.join(criteria, ' AND '); //join() 메서드는 배열의 모든 요소를 연결해 하나의 문자열로 반환
            }
        }

        // 페이지 당 표시할 제품 개수
        Integer pageSize = ProductController.PAGE_SIZE;
        // 현재 페이지의 첫 번째 제품이 목록에서 어디에 위치하는지를 나타내는 값
        Integer offset = (pageNumber - 1) * pageSize;
        
        // 페이징된 결과를 저장
        PagedResult result = new PagedResult();
        
        result.pageSize = pageSize;
        // 현재 페이지 번호 
        result.pageNumber = pageNumber;

        result.totalItemCount = Database.countQuery(
            'SELECT count() FROM Product__c ' + whereClause
        );
        result.records = Database.query(
            'SELECT Id, Name, MSRP__c, Description__c, Category__c, Level__c, Picture_URL__c, Material__c FROM Product__c ' +
                whereClause +
                // WITH SECURITY_ENFORCED : 데이터 액세스 권한 검사를 통해 사용자의 데이터 액세스 권한과 객체 보안 규칙을 적용하여 쿼리 결과를 필터링,
                // 이 옵션을 사용하면 사용자가 쿼리를 수행하는 시점에 객체에 대한 데이터 액세스 권한을 확인하고, 해당 사용자가 액세스 권한이 있는 레코드만 반환
                ' WITH SECURITY_ENFORCED' + 
                ' ORDER BY Name LIMIT :pageSize OFFSET :offset' // 쿼리 결과에서 건너뛸 시작 레코드의 개수를 지정해서 페이지별로 필요한 범위의 결과만 가져옴
        );
        // 페이징처리 정보 return
        return result;
    }

    @AuraEnabled(Cacheable=true scope='global')
    public static Product__c[] getSimilarProducts(Id productId, Id familyId) {
        return [
            SELECT
                Id,
                Name,
                MSRP__c,
                Description__c,
                Category__c,
                Level__c,
                Picture_URL__c,
                Material__c
            FROM Product__c
            WHERE Product_Family__c = :familyId AND Id != :productId
            WITH SECURITY_ENFORCED
        ];
    }
}
