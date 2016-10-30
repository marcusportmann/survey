/*
 * Copyright 2016 Marcus Portmann
 * All rights reserved.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package digital.survey.model;

//~--- non-JDK imports --------------------------------------------------------

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.enterprise.context.ApplicationScoped;
import javax.enterprise.inject.Default;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import java.util.List;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyService</code> class provides the Survey Service implementation.
 *
 * @author Marcus Portmann
 */
@SuppressWarnings("JpaQlInspection")
@ApplicationScoped
@Default
public class SurveyService
  implements ISurveyService
{
  /* Logger */
  @SuppressWarnings("unused")
  private static final Logger logger = LoggerFactory.getLogger(SurveyService.class);

  /* Entity Manager */
  @PersistenceContext(unitName = "Application")
  private EntityManager entityManager;

  /**
   * Constructs a new <code>SurveyService</code>.
   */
  public SurveyService() {}

  /**
   * Delete the survey audience.
   *
   * @param surveyAudience the survey audience to delete
   *
   * @return <code>true</code> if the survey audience was deleted or <code>false</code> otherwise
   *
   * @throws SurveyServiceException
   */
  @Transactional
  public boolean deleteSurveyAudience(SurveyAudience surveyAudience)
    throws SurveyServiceException
  {
    try
    {
      if (entityManager.contains(surveyAudience))
      {
        entityManager.remove(surveyAudience);
        entityManager.flush();

        return true;
      }
      else
      {
        return deleteSurveyAudience(surveyAudience.getId());
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to delete the survey audience with ID ("
          + surveyAudience.getId() + ")", e);
    }
  }

  /**
   * Delete the survey audience with the specified ID.
   *
   * @param id  the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *            audience
   *
   * @return <code>true</code> if the survey audience was deleted or <code>false</code> otherwise
   *
   * @throws SurveyServiceException
   */
  @Transactional
  public boolean deleteSurveyAudience(UUID id)
    throws SurveyServiceException
  {
    try
    {
      Query query = entityManager.createQuery("delete from SurveyAudience sa where sa.id = :id");

      query.setParameter("id", id);

      return (query.executeUpdate() > 0);
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to delete the survey audience with ID (" + id + ")",
          e);
    }
  }

  /**
   * Delete the survey audience member.
   *
   * @param surveyAudienceMember the survey audience member to delete
   *
   * @return
   *
   * @throws SurveyServiceException
   */
  @Transactional
  public boolean deleteSurveyAudienceMember(SurveyAudienceMember surveyAudienceMember)
    throws SurveyServiceException
  {
    try
    {
      if (entityManager.contains(surveyAudienceMember))
      {
        entityManager.remove(surveyAudienceMember);
        entityManager.flush();

        return true;
      }
      else
      {
        return deleteSurveyAudienceMember(surveyAudienceMember.getId());
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to delete the survey audience member with ID ("
          + surveyAudienceMember.getId() + ")", e);
    }

  }

  /**
   * Delete the survey audience member with the specified ID.
   *
   * @param id  the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *            audience member
   *
   * @return <code>true</code> if the survey audience member was deleted or <code>false</code>
   *         otherwise
   *
   * @throws SurveyServiceException
   */
  @Transactional
  public boolean deleteSurveyAudienceMember(UUID id)
    throws SurveyServiceException
  {
    try
    {
      Query query = entityManager.createQuery(
          "delete from SurveyAudienceMember sam where sam.id = :id");

      query.setParameter("id", id);

      return (query.executeUpdate() > 0);
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to delete the survey audience member with ID (" + id
          + ")", e);
    }
  }

  /**
   * Delete the survey definition.
   *
   * @param surveyDefinition the survey definition to delete
   *
   * @return <code>true</code> if the survey definition was deleted or <code>false</code> otherwise
   *
   * @throws SurveyServiceException
   */
  @Transactional
  public boolean deleteSurveyDefinition(SurveyDefinition surveyDefinition)
    throws SurveyServiceException
  {
    try
    {
      if (entityManager.contains(surveyDefinition))
      {
        entityManager.remove(surveyDefinition);
        entityManager.flush();

        return true;
      }
      else
      {
        return deleteSurveyDefinition(surveyDefinition.getId(), surveyDefinition.getVersion());
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to delete the survey definition with ID ("
          + surveyDefinition.getId() + ") and version (" + surveyDefinition.getVersion() + ")", e);
    }
  }

  /**
   * Delete all versions of the survey definition with the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to, along with the version of the
   *           survey definition, uniquely identify the survey definitions
   *
   * @return <code>true</code> if all versions of the survey definition were deleted or
   *        <code>false</code> otherwise
   *
   * @throws SurveyServiceException
   */
  @Transactional
  public boolean deleteSurveyDefinition(UUID id)
    throws SurveyServiceException
  {
    try
    {
      Query query = entityManager.createQuery("delete from SurveyDefinition sd where sd.id = :id");

      query.setParameter("id", id);

      return (query.executeUpdate() > 0);
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to delete all versions of the survey definition with ID (" + id + ")", e);
    }
  }

  /**
   * Delete the survey definition with the specified ID and version.
   *
   * @param id      the Universally Unique Identifier (UUID) used to, along with the version of the
   *                survey definition, uniquely identify the survey definition
   * @param version the version of the survey definition
   *
   * @return <code>true</code> if the survey definition was deleted or <code>false</code> otherwise
   *
   * @throws SurveyServiceException
   */
  @Transactional
  public boolean deleteSurveyDefinition(UUID id, int version)
    throws SurveyServiceException
  {
    try
    {
      Query query = entityManager.createQuery(
          "delete from SurveyDefinition sd where sd.id = :id AND sd.version = :version");

      query.setParameter("id", id);
      query.setParameter("version", version);

      return (query.executeUpdate() > 0);
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to delete the survey definition with ID (" + id
          + ") and version (" + version + ")", e);
    }
  }

  /**
   * Delete the survey instance.
   *
   * @param surveyInstance the survey instance to delete
   *
   * @return <code>true</code> if the survey instance was deleted or <code>false</code> otherwise
   *
   * @throws SurveyServiceException
   */
  @Transactional
  public boolean deleteSurveyInstance(SurveyInstance surveyInstance)
    throws SurveyServiceException
  {
    try
    {
      if (entityManager.contains(surveyInstance))
      {
        entityManager.remove(surveyInstance);
        entityManager.flush();

        return true;
      }
      else
      {
        return deleteSurveyInstance(surveyInstance.getId());
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to delete the survey instance with ID ("
          + surveyInstance.getId() + ")", e);
    }
  }

  /**
   * Delete the survey instance with the specified ID.
   *
   * @param id  the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *            instance
   *
   * @return <code>true</code> if the survey instance was deleted or <code>false</code> otherwise
   *
   * @throws SurveyServiceException
   */
  @Transactional
  public boolean deleteSurveyInstance(UUID id)
    throws SurveyServiceException
  {
    try
    {
      Query query = entityManager.createQuery("delete from SurveyInstance si where si.id = :id");

      query.setParameter("id", id);

      return (query.executeUpdate() > 0);
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to delete the survey instance with ID (" + id + ")",
          e);
    }
  }

  /**
   * Delete the survey request.
   *
   * @param surveyRequest the survey request to delete
   *
   * @return <code>true</code> if the survey request was deleted or <code>false</code> otherwise
   *
   * @throws SurveyServiceException
   */
  @Transactional
  public boolean deleteSurveyRequest(SurveyRequest surveyRequest)
    throws SurveyServiceException
  {
    try
    {
      if (entityManager.contains(surveyRequest))
      {
        entityManager.remove(surveyRequest);
        entityManager.flush();

        return true;
      }
      else
      {
        return deleteSurveyRequest(surveyRequest.getId());
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to delete the survey request with ID ("
          + surveyRequest.getId() + ")", e);
    }
  }

  /**
   * Delete the survey request with the specified ID.
   *
   * @param id  the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *            request
   *
   * @return <code>true</code> if the survey request was deleted or <code>false</code> otherwise
   *
   * @throws SurveyServiceException
   */
  @Transactional
  public boolean deleteSurveyRequest(UUID id)
    throws SurveyServiceException
  {
    try
    {
      Query query = entityManager.createQuery("delete from SurveyRequest sr where sr.id = :id");

      query.setParameter("id", id);

      return (query.executeUpdate() > 0);
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to delete the survey request with ID (" + id + ")",
          e);
    }
  }

  /**
   * Delete the survey response.
   *
   * @param surveyResponse the survey response to delete
   *
   * @return <code>true</code> if the survey response was deleted or <code>false</code> otherwise
   *
   * @throws SurveyServiceException
   */
  @Transactional
  public boolean deleteSurveyResponse(SurveyResponse surveyResponse)
    throws SurveyServiceException
  {
    try
    {
      if (entityManager.contains(surveyResponse))
      {
        entityManager.remove(surveyResponse);
        entityManager.flush();

        return true;
      }
      else
      {
        return deleteSurveyResponse(surveyResponse.getId());
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to delete the survey response with ID ("
          + surveyResponse.getId() + ")", e);
    }
  }

  /**
   * Delete the survey response with the specified ID.
   *
   * @param id  the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *            response
   *
   * @return <code>true</code> if the survey response was deleted or <code>false</code> otherwise
   *
   * @throws SurveyServiceException
   */
  @Transactional
  public boolean deleteSurveyResponse(UUID id)
    throws SurveyServiceException
  {
    try
    {
      Query query = entityManager.createQuery("delete from SurveyResponse sr where sr.id = :id");

      query.setParameter("id", id);

      return (query.executeUpdate() > 0);
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to delete the survey response with ID (" + id + ")",
          e);
    }
  }

  /**
   * Retrieve the filtered survey audience members for the survey audience.
   *
   * @param id     the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *               audience
   * @param filter the filter used to limit the matching survey audience members
   *
   * @return the filtered survey audiences members for the survey audience
   *
   * @throws SurveyServiceException
   */
  public List<SurveyAudienceMember> getFilteredMembersForSurveyAudience(UUID id, String filter)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sam FROM SurveyAudienceMember sam"
          + " WHERE sam.audience.id = :id AND ((UPPER(sam.firstName) LIKE :filter)"
          + " OR (UPPER(sam.lastName) LIKE :filter) OR (UPPER(sam.email) LIKE :filter))";

      TypedQuery<SurveyAudienceMember> query = entityManager.createQuery(sql,
          SurveyAudienceMember.class);

      query.setParameter("id", id);
      query.setParameter("filter", "%" + filter.toUpperCase() + "%");

      return query.getResultList();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the survey audience members for the survey audience with ID (" + id
          + ") matching the filter (" + filter + ")", e);
    }
  }

  /**
   * Retrieve the filtered survey audiences for the organisation.
   *
   * @param id     the Universally Unique Identifier (UUID) used to uniquely identify the
   *               organisation
   * @param filter the filter used to limit the matching survey audiences
   *
   * @return the filtered survey audiences for the organisation
   *
   * @throws SurveyServiceException
   */
  public List<SurveyAudience> getFilteredSurveyAudiencesForOrganisation(UUID id, String filter)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sa FROM SurveyAudience sa WHERE sa.organisation.id = :id"
          + " AND (UPPER(sa.name) LIKE :filter)";

      TypedQuery<SurveyAudience> query = entityManager.createQuery(sql, SurveyAudience.class);

      query.setParameter("id", id);
      query.setParameter("filter", "%" + filter.toUpperCase() + "%");

      return query.getResultList();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the survey audiences for the organisation with ID (" + id
          + ") matching the filter (" + filter + ")", e);
    }
  }

  /**
   * Retrieve the summaries for the latest versions of the filtered survey definitions for the
   * organisation.
   *
   * @param id     the Universally Unique Identifier (UUID) used to uniquely identify the
   *               organisation
   * @param filter the filter used to limit the matching survey definitions
   *
   * @return the summaries for the latest versions of the filtered survey definitions for the
   *         organisation
   *
   * @throws SurveyServiceException
   */
  public List<SurveyDefinitionSummary> getFilteredSurveyDefinitionSummariesForOrganisation(UUID id,
      String filter)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT SD.ID, SD.VERSION, SD.NAME FROM SURVEY.SURVEY_DEFINITIONS SD"
          + " JOIN (SELECT ID, MAX(VERSION) AS LATEST_VERSION FROM SURVEY.SURVEY_DEFINITIONS"
          + " GROUP BY ID) LATEST ON (SD.VERSION = LATEST.LATEST_VERSION AND SD.ID = LATEST.ID)"
          + " WHERE SD.ORGANISATION_ID = ?1 AND UPPER(SD.NAME) LIKE ?2";

      Query query = entityManager.createNativeQuery(sql, SurveyDefinitionSummary.class);

      query.setParameter(1, id);
      query.setParameter(2, "%" + filter.toUpperCase() + "%");

      return query.getResultList();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the summaries for the filtered latest versions of the survey"
          + " definitions for the organisation with ID (" + id + ")", e);
    }
  }

  /**
   * Retrieve the filtered survey instances for all versions of the survey definition.
   *
   * @param id     the Universally Unique Identifier (UUID) used to identify the survey definition
   *               the survey instances are associated with
   * @param filter the filter used to limit the matching survey definitions
   *
   * @return the filtered survey instances for all versions of the survey definition
   *
   * @throws SurveyServiceException
   */
  public List<SurveyInstance> getFilteredSurveyInstancesForSurveyDefinition(UUID id, String filter)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT si FROM SurveyInstance si JOIN si.definition sd"
          + " WHERE sd.id = :id AND (UPPER(si.name) LIKE :filter)";

      TypedQuery<SurveyInstance> query = entityManager.createQuery(sql, SurveyInstance.class);

      query.setParameter("id", id);
      query.setParameter("filter", "%" + filter.toUpperCase() + "%");

      return query.getResultList();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the filtered survey instances for the survey definition with ID ("
          + id + ")", e);
    }
  }

  /**
   * Retrieve the filtered survey requests for the survey instance.
   *
   * @param id     the Universally Unique Identifier (UUID) used to identify the survey instance
   *               the survey requests are associated with
   * @param filter the filter used to limit the matching survey requests
   *
   * @return the filtered survey requests for the survey instance
   *
   * @throws SurveyServiceException
   */
  public List<SurveyRequest> getFilteredSurveyRequestsForSurveyInstance(UUID id, String filter)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sr FROM SurveyRequest sr JOIN sr.instance si WHERE si.id = :id"
          + " AND ((UPPER(sr.firstName) LIKE :filter) OR (UPPER(sr.lastName) LIKE :filter)"
          + " OR (UPPER(sr.email) LIKE :filter))";

      TypedQuery<SurveyRequest> query = entityManager.createQuery(sql, SurveyRequest.class);

      query.setParameter("id", id);
      query.setParameter("filter", "%" + filter.toUpperCase() + "%");

      return query.getResultList();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the filtered survey requests for the survey instance with ID (" + id
          + ")", e);
    }
  }

  /**
   * Retrieve the filtered survey responses for the survey instance.
   *
   * @param id     the Universally Unique Identifier (UUID) used to identify the survey instance
   *               the survey responses are associated with
   * @param filter the filter used to limit the matching survey responses
   *
   * @return the filtered survey responses for the survey instance
   *
   * @throws SurveyServiceException
   */
  public List<SurveyResponse> getFilteredSurveyResponsesForSurveyInstance(UUID id, String filter)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sr FROM SurveyResponse sr JOIN sr.instance si"
          + " JOIN sr.request req WHERE si.id = :id AND ((UPPER(req.firstName) LIKE :filter)"
          + " OR (UPPER(req.lastName) LIKE :filter) OR (UPPER(req.email) LIKE :filter))";

      TypedQuery<SurveyResponse> query = entityManager.createQuery(sql, SurveyResponse.class);

      query.setParameter("id", id);
      query.setParameter("filter", "%" + filter.toUpperCase() + "%");

      return query.getResultList();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the filtered survey responses for the survey instance with ID (" + id
          + ")", e);
    }
  }

  /**
   * Retrieve the latest version number for the survey definition.
   *
   * @param id the Universally Unique Identifier (UUID) used to identify the survey definition
   *
   * @return the latest version number for the survey definition or 0 if the survey definition
   *         could not be found
   *
   * @throws SurveyServiceException
   */
  public int getLatestVersionNumberForSurveyDefinition(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT MAX(sd.version) FROM SurveyDefinition sd WHERE sd.id = :id";

      Query query = entityManager.createQuery(sql);

      query.setParameter("id", id);

      return ((Number) query.getSingleResult()).intValue();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the latest version number for the survey definition with ID (" + id
          + ")", e);
    }
  }

  /**
   * Retrieve the survey audience members for the survey audience.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           audience
   *
   * @return the survey audiences members for the survey audience
   *
   * @throws SurveyServiceException
   */
  public List<SurveyAudienceMember> getMembersForSurveyAudience(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sam FROM SurveyAudienceMember sam WHERE sam.audience.id = :id";

      TypedQuery<SurveyAudienceMember> query = entityManager.createQuery(sql,
          SurveyAudienceMember.class);

      query.setParameter("id", id);

      return query.getResultList();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the survey audience members for the survey audience with ID (" + id
          + ")", e);
    }
  }

  /**
   * Returns the number of filtered survey audience members for the survey audience.
   *
   * @param id     the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *               audience
   * @param filter the filter used to limit the matching survey audience members
   *
   * @return the number of filtered survey audience members for the survey audience
   *
   * @throws SurveyServiceException
   */
  public int getNumberOfFilteredMembersForSurveyAudience(UUID id, String filter)
    throws SurveyServiceException
  {
    try
    {
      Query query = entityManager.createQuery("SELECT COUNT(sam.id) FROM SurveyAudienceMember sam "
          + " WHERE sam.audience.id = :id AND ((UPPER(sam.firstName) LIKE :filter)"
          + " OR (UPPER(sam.lastName) LIKE :filter) OR (UPPER(sam.email) LIKE :filter))");

      query.setParameter("id", id);
      query.setParameter("filter", "%" + filter.toUpperCase() + "%");

      return ((Number) query.getSingleResult()).intValue();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the number of survey audience members for the survey audience with ID ("
          + id + ") matching the filter (" + filter + ")", e);
    }
  }

  /**
   * Returns the number of filtered survey audiences for the organisation.
   *
   * @param id     the Universally Unique Identifier (UUID) used to uniquely identify the
   *               organisation
   * @param filter the filter used to limit the matching survey audiences
   *
   * @return the number of filtered survey audiences for the organisation
   *
   * @throws SurveyServiceException
   */
  public int getNumberOfFilteredSurveyAudiencesForOrganisation(UUID id, String filter)
    throws SurveyServiceException
  {
    try
    {
      Query query = entityManager.createQuery("SELECT COUNT(sa.id) FROM SurveyAudience sa"
          + " WHERE sa.organisation.id = :id AND (UPPER(sa.name) LIKE :filter)");

      query.setParameter("id", id);
      query.setParameter("filter", "%" + filter.toUpperCase() + "%");

      return ((Number) query.getSingleResult()).intValue();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the number of survey audiences for the organisation with ID (" + id
          + ") matching the filter (" + filter + ")", e);
    }
  }

  /**
   * Retrieve the number of filtered survey definitions for the organisation.
   *
   * @param id     the Universally Unique Identifier (UUID) used to uniquely identify the
   *               organisation
   * @param filter the filter used to limit the matching survey definitions
   *
   * @return the number of filtered survey definitions for the organisation
   *
   * @throws SurveyServiceException
   */
  public int getNumberOfFilteredSurveyDefinitionsForOrganisation(UUID id, String filter)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT COUNT(DISTINCT SD.ID) FROM SURVEY.SURVEY_DEFINITIONS SD"
          + " WHERE SD.ORGANISATION_ID = ?1 AND UPPER(SD.NAME) LIKE ?2";

      Query query = entityManager.createNativeQuery(sql);

      query.setParameter(1, id);
      query.setParameter(2, "%" + filter.toUpperCase() + "%");

      return ((Number) query.getSingleResult()).intValue();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the number of filtered latest versions"
          + " of the survey definitions for the organisation with ID (" + id + ")", e);
    }
  }

  /**
   * Retrieve the number of filtered survey instances for all versions of the survey definition.
   *
   * @param id     the Universally Unique Identifier (UUID) used to identify the survey definition
   *               the survey instances are associated with
   * @param filter the filter used to limit the matching survey definitions
   *
   * @return the number of filtered survey instances for all versions of the survey definition
   *
   * @throws SurveyServiceException
   */
  public int getNumberOfFilteredSurveyInstancesForSurveyDefinition(UUID id, String filter)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT si FROM SurveyInstance si JOIN si.definition sd"
          + " WHERE sd.id = :id AND (UPPER(si.name) LIKE :filter)";

      Query query = entityManager.createQuery(sql);

      query.setParameter("id", id);
      query.setParameter("filter", "%" + filter.toUpperCase() + "%");

      return ((Number) query.getSingleResult()).intValue();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the number of filtered survey instances for the survey definition with"
          + " ID (" + id + ")", e);
    }
  }

  /**
   * Retrieve the number of filtered survey requests for the survey instance.
   *
   * @param id     the Universally Unique Identifier (UUID) used to identify the survey instance
   *               the survey requests are associated with
   * @param filter the filter used to limit the matching survey requests
   *
   * @return the number of filtered survey requests for the survey instance
   *
   * @throws SurveyServiceException
   */
  public int getNumberOfFilteredSurveyRequestsForSurveyInstance(UUID id, String filter)
    throws SurveyServiceException
  {
    try
    {
      String sql =
          "SELECT COUNT(sr.id) FROM SurveyRequest sr JOIN sr.instance si WHERE si.id = :id"
          + " AND ((UPPER(sr.firstName) LIKE :filter) OR (UPPER(sr.lastName) LIKE :filter)"
          + " OR (UPPER(sr.email) LIKE :filter))";

      Query query = entityManager.createQuery(sql);

      query.setParameter("id", id);
      query.setParameter("filter", "%" + filter.toUpperCase() + "%");

      return ((Number) query.getSingleResult()).intValue();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the number of filtered survey requests for the survey instance with ID ("
          + id + ")", e);
    }
  }

  /**
   * Retrieve the number of filtered survey responses for the survey instance.
   *
   * @param id     the Universally Unique Identifier (UUID) used to identify the survey instance
   *               the survey responses are associated with
   * @param filter the filter used to limit the matching survey responses
   *
   * @return the number of filtered survey responses for the survey instance
   *
   * @throws SurveyServiceException
   */
  public int getNumberOfFilteredSurveyResponsesForSurveyInstance(UUID id, String filter)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT COUNT(sr.id) FROM SurveyResponse sr JOIN sr.instance si"
          + " JOIN sr.request req WHERE si.id = :id AND ((UPPER(req.firstName) LIKE :filter)"
          + " OR (UPPER(req.lastName) LIKE :filter) OR (UPPER(req.email) LIKE :filter))";

      Query query = entityManager.createQuery(sql);

      query.setParameter("id", id);
      query.setParameter("filter", "%" + filter.toUpperCase() + "%");

      return ((Number) query.getSingleResult()).intValue();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the number of filtered survey responses for the survey instance with ID ("
          + id + ")", e);
    }
  }

  /**
   * Returns the number of members for the survey audience.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           audience
   *
   * @return the number of members for the survey audience
   *
   * @throws SurveyServiceException
   */
  public int getNumberOfMembersForSurveyAudience(UUID id)
    throws SurveyServiceException
  {
    try
    {
      Query query = entityManager.createQuery("SELECT COUNT(sam.id) FROM SurveyAudienceMember sam"
          + " WHERE sam.audience.id = :id");

      query.setParameter("id", id);

      return ((Number) query.getSingleResult()).intValue();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the number of members for the survey audience with ID (" + id + ")",
          e);
    }
  }

  /**
   * Returns the number of survey audiences for the organisation.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the organisation
   *
   * @return the number of survey audiences for the organisation
   *
   * @throws SurveyServiceException
   */
  public int getNumberOfSurveyAudiencesForOrganisation(UUID id)
    throws SurveyServiceException
  {
    try
    {
      Query query = entityManager.createQuery("SELECT COUNT(sa.id) FROM SurveyAudience sa"
          + " WHERE sa.organisation.id = :id");

      query.setParameter("id", id);

      return ((Number) query.getSingleResult()).intValue();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the number of survey audiences for the organisation with ID (" + id
          + ")", e);
    }
  }

  /**
   * Retrieve the number of survey definitions for the organisation.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the organisation
   *
   * @return the number of survey definitions for the organisation
   *
   * @throws SurveyServiceException
   */
  public int getNumberOfSurveyDefinitionsForOrganisation(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT COUNT(DISTINCT SD.ID) FROM SURVEY.SURVEY_DEFINITIONS SD"
          + " WHERE SD.ORGANISATION_ID = ?1";

      Query query = entityManager.createNativeQuery(sql);

      query.setParameter(1, id);

      int result =  ((Number) query.getSingleResult()).intValue();

      return result;
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the number of latest versions of the"
          + " survey definitions for the organisation with ID (" + id + ")", e);
    }
  }

  /**
   * Retrieve the number of survey instances for all versions of the survey definition.
   *
   * @param id     the Universally Unique Identifier (UUID) used to identify the survey definition
   *               the survey instances are associated with
   *
   * @return the number of survey instances for all versions of the survey definition
   *
   * @throws SurveyServiceException
   */
  public int getNumberOfSurveyInstancesForSurveyDefinition(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT COUNT(si.id) FROM SurveyInstance si JOIN si.definition sd"
          + " WHERE sd.id = :id";

      Query query = entityManager.createQuery(sql);

      query.setParameter("id", id);

      return ((Number) query.getSingleResult()).intValue();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the survey instances for the survey definition with ID (" + id + ")",
          e);
    }
  }

  /**
   * Retrieve the number of survey requests for the survey instance.
   *
   * @param id the Universally Unique Identifier (UUID) used to identify the survey instance the
   *           survey requests are associated with
   *
   * @return the number of survey requests for the survey instance
   *
   * @throws SurveyServiceException
   */
  public int getNumberOfSurveyRequestsForSurveyInstance(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT COUNT(sr.id) FROM SurveyRequest sr JOIN sr.instance si"
          + " WHERE si.id = :id";

      Query query = entityManager.createQuery(sql);

      query.setParameter("id", id);

      return ((Number) query.getSingleResult()).intValue();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the number of survey requests for the survey instance with ID (" + id
          + ")", e);
    }
  }

  /**
   * Retrieve the number of survey responses for the survey instance.
   *
   * @param id the Universally Unique Identifier (UUID) used to identify the survey instance the
   *           survey responses are associated with
   *
   * @return the number of survey responses for the survey instance
   *
   * @throws SurveyServiceException
   */
  public int getNumberOfSurveyResponsesForSurveyInstance(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT COUNT(sr.id) FROM SurveyResponse sr JOIN sr.instance si"
          + " WHERE si.id = :id";

      Query query = entityManager.createQuery(sql);

      query.setParameter("id", id);

      return ((Number) query.getSingleResult()).intValue();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the number of survey responses for the survey instance with ID ("
          + id + ")", e);
    }
  }

  /**
   * Retrieve the survey audience identified by the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           audience
   *
   * @return the survey audience identified by the specified ID or <code>null</code> if the survey
   *         audience could not be found
   *
   * @throws SurveyServiceException
   */
  public SurveyAudience getSurveyAudience(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sa FROM SurveyAudience sa WHERE sa.id = :id";

      TypedQuery<SurveyAudience> query = entityManager.createQuery(sql, SurveyAudience.class);

      query.setParameter("id", id);

      List<SurveyAudience> surveyAudiences = query.getResultList();

      if (surveyAudiences.size() == 0)
      {
        return null;
      }
      else
      {
        return surveyAudiences.get(0);
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the survey audience (" + id + ")", e);
    }
  }

  /**
   * Retrieve the survey audience member identified by the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           audience member
   *
   * @return the survey audience member identified by the specified ID or <code>null</code> if the
   *         survey audience member could not be found
   *
   * @throws SurveyServiceException
   */
  public SurveyAudienceMember getSurveyAudienceMember(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sam FROM SurveyAudienceMember sam WHERE sam.id = :id";

      TypedQuery<SurveyAudienceMember> query = entityManager.createQuery(sql,
          SurveyAudienceMember.class);

      query.setParameter("id", id);

      List<SurveyAudienceMember> surveyAudienceMembers = query.getResultList();

      if (surveyAudienceMembers.size() == 0)
      {
        return null;
      }
      else
      {
        return surveyAudienceMembers.get(0);
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the survey audience member (" + id
          + ")", e);
    }
  }

  /**
   * Retrieve the survey audiences for the organisation.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the organisation
   *
   * @return the survey audiences for the organisation
   *
   * @throws SurveyServiceException
   */
  public List<SurveyAudience> getSurveyAudiencesForOrganisation(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sa FROM SurveyAudience sa WHERE sa.organisation.id = :id";

      TypedQuery<SurveyAudience> query = entityManager.createQuery(sql, SurveyAudience.class);

      query.setParameter("id", id);

      return query.getResultList();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the survey audiences for the organisation with ID (" + id + ")", e);
    }
  }

  /**
   * Retrieve the survey definition identified by the specified ID and version.
   *
   * @param id      the Universally Unique Identifier (UUID) used to, along with the version of the
   *                survey definition, uniquely identify the survey definition
   * @param version the version of the survey definition
   *
   * @return the survey definition identified by the specified ID and version or <code>null</code>
   *         if the survey definition could not be found
   *
   * @throws SurveyServiceException
   */
  public SurveyDefinition getSurveyDefinition(UUID id, int version)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sd FROM SurveyDefinition sd WHERE sd.id = :id AND sd.version = :version";

      TypedQuery<SurveyDefinition> query = entityManager.createQuery(sql, SurveyDefinition.class);

      query.setParameter("id", id);
      query.setParameter("version", version);

      List<SurveyDefinition> surveyDefinitions = query.getResultList();

      if (surveyDefinitions.size() == 0)
      {
        return null;
      }
      else
      {
        return surveyDefinitions.get(0);
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the version (" + version
          + ") of the survey definition (" + id + ")", e);
    }
  }

  /**
   * Retrieve the summaries for the latest versions of the survey definitions for the organisation.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the organisation
   *
   * @return the summaries for the latest versions of the survey definitions for the organisation
   *
   * @throws SurveyServiceException
   */
  public List<SurveyDefinitionSummary> getSurveyDefinitionSummariesForOrganisation(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT SD.ID, SD.VERSION, SD.NAME FROM SURVEY.SURVEY_DEFINITIONS SD"
          + " JOIN (SELECT ID, MAX(VERSION) AS LATEST_VERSION FROM SURVEY.SURVEY_DEFINITIONS"
          + " GROUP BY ID) LATEST ON (SD.VERSION = LATEST.LATEST_VERSION AND SD.ID = LATEST.ID)"
          + " WHERE SD.ORGANISATION_ID = ?1";

      Query query = entityManager.createNativeQuery(sql, SurveyDefinitionSummary.class);

      query.setParameter(1, id);

      return query.getResultList();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the summaries for the latest versions of the survey definitions for"
          + " the organisation with ID (" + id + ")", e);
    }
  }

  /**
   * Retrieve the summary for the survey definition identified by the specified ID and version.
   *
   * @param id      the Universally Unique Identifier (UUID) used to, along with the version of the
   *                survey definition, uniquely identify the survey definition
   * @param version the version of the survey definition
   *
   * @return the summary for the survey definition identified by the specified ID and version or
   *         <code>null</code> if the survey definition could not be found
   *
   * @throws SurveyServiceException
   */
  public SurveyDefinitionSummary getSurveyDefinitionSummary(UUID id, int version)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sds FROM SurveyDefinitionSummary sds WHERE sds.id = :id"
          + " AND sds .version = :version";

      TypedQuery<SurveyDefinitionSummary> query = entityManager.createQuery(sql,
          SurveyDefinitionSummary.class);

      query.setParameter("id", id);
      query.setParameter("version", version);

      List<SurveyDefinitionSummary> surveyDefinitionSummaries = query.getResultList();

      if (surveyDefinitionSummaries.size() == 0)
      {
        return null;
      }
      else
      {
        return surveyDefinitionSummaries.get(0);
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the summary for the version (" + version
          + ") of the survey definition (" + id + ")", e);
    }

  }

  /**
   * Retrieve the survey instance identified by the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey instance
   *
   * @return the survey instance identified by the specified ID or <code>null</code> if the survey
   *         instance could not be found
   *
   * @throws SurveyServiceException
   */
  public SurveyInstance getSurveyInstance(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT si FROM SurveyInstance si WHERE si.id = :id";

      TypedQuery<SurveyInstance> query = entityManager.createQuery(sql, SurveyInstance.class);

      query.setParameter("id", id);

      List<SurveyInstance> surveyInstances = query.getResultList();

      if (surveyInstances.size() == 0)
      {
        return null;
      }
      else
      {
        return surveyInstances.get(0);
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the survey instance (" + id + ")", e);
    }
  }

  /**
   * Retrieve the survey instances for all versions of the survey definition.
   *
   * @param id     the Universally Unique Identifier (UUID) used to identify the survey definition
   *               the survey instances are associated with
   *
   * @return the survey instances for all versions of the survey definition
   *
   * @throws SurveyServiceException
   */
  public List<SurveyInstance> getSurveyInstancesForSurveyDefinition(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT si FROM SurveyInstance si JOIN si.definition sd WHERE sd.id = :id";

      TypedQuery<SurveyInstance> query = entityManager.createQuery(sql, SurveyInstance.class);

      query.setParameter("id", id);

      return query.getResultList();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the survey instances for the survey definition with ID (" + id + ")",
          e);
    }
  }

  /**
   * Retrieve the survey request identified by the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey request
   *
   * @return the survey request identified by the specified ID or <code>null</code> if the survey
   *         request could not be found
   *
   * @throws SurveyServiceException
   */
  public SurveyRequest getSurveyRequest(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sr FROM SurveyRequest sr WHERE sr.id = :id";

      TypedQuery<SurveyRequest> query = entityManager.createQuery(sql, SurveyRequest.class);

      query.setParameter("id", id);

      List<SurveyRequest> surveyRequests = query.getResultList();

      if (surveyRequests.size() == 0)
      {
        return null;
      }
      else
      {
        return surveyRequests.get(0);
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the survey request (" + id + ")", e);
    }
  }

  /**
   * Retrieve the survey requests for the survey instance.
   *
   * @param id the Universally Unique Identifier (UUID) used to identify the survey instance the
   *           survey requests are associated with
   *
   * @return the survey requests for the survey instance
   *
   * @throws SurveyServiceException
   */
  public List<SurveyRequest> getSurveyRequestsForSurveyInstance(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sr FROM SurveyRequest sr JOIN sr.instance si WHERE si.id = :id";

      TypedQuery<SurveyRequest> query = entityManager.createQuery(sql, SurveyRequest.class);

      query.setParameter("id", id);

      return query.getResultList();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the survey requests for the survey instance with ID (" + id + ")", e);
    }
  }

  /**
   * Retrieve the survey response identified by the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           response
   *
   * @return the survey response identified by the specified ID or <code>null</code> if the survey
   *         response could not be found
   *
   * @throws SurveyServiceException
   */
  public SurveyResponse getSurveyResponse(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sr FROM SurveyResponse sr WHERE sr.id = :id";

      TypedQuery<SurveyResponse> query = entityManager.createQuery(sql, SurveyResponse.class);

      query.setParameter("id", id);

      List<SurveyResponse> surveyResponses = query.getResultList();

      if (surveyResponses.size() == 0)
      {
        return null;
      }
      else
      {
        return surveyResponses.get(0);
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the survey response (" + id + ")", e);
    }
  }

  /**
   * Retrieve the survey responses for the survey instance.
   *
   * @param id the Universally Unique Identifier (UUID) used to identify the survey instance the
   *           survey responses are associated with
   *
   * @return the survey responses for the survey instance
   *
   * @throws SurveyServiceException
   */
  public List<SurveyResponse> getSurveyResponsesForSurveyInstance(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sr FROM SurveyResponse sr JOIN sr.instance si WHERE si.id = :id";

      TypedQuery<SurveyResponse> query = entityManager.createQuery(sql, SurveyResponse.class);

      query.setParameter("id", id);

      return query.getResultList();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the survey responses for the survey instance with ID (" + id + ")",
          e);
    }
  }

  /**
   * Save the survey audience.
   *
   * @param surveyAudience the survey audience
   *
   * @return the saved survey audience
   *
   * @throws SurveyServiceException
   */
  @Transactional
  public SurveyAudience saveSurveyAudience(SurveyAudience surveyAudience)
    throws SurveyServiceException
  {
    try
    {
      if (!entityManager.contains(surveyAudience))
      {
        surveyAudience = entityManager.merge(surveyAudience);

        entityManager.flush();

        entityManager.detach(surveyAudience);
      }

      return surveyAudience;
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to save the survey audience with ID ("
          + surveyAudience.getId() + ")", e);
    }
  }

  /**
   * Save the survey audience member.
   *
   * @param surveyAudienceMember the survey audience member
   *
   * @return the saved survey response
   *
   * @throws SurveyServiceException
   */
  @Transactional
  public SurveyAudienceMember saveSurveyAudienceMember(SurveyAudienceMember surveyAudienceMember)
    throws SurveyServiceException
  {
    try
    {
      if (!entityManager.contains(surveyAudienceMember))
      {
        surveyAudienceMember = entityManager.merge(surveyAudienceMember);

        entityManager.flush();

        entityManager.detach(surveyAudienceMember);
      }

      return surveyAudienceMember;
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to save the survey audience member with ID ("
          + surveyAudienceMember.getId() + ")", e);
    }
  }

  /**
   * Save the survey definition.
   *
   * @param surveyDefinition the survey definition
   *
   * @return the saved survey definition
   *
   * @throws SurveyServiceException
   */
  @Transactional
  public SurveyDefinition saveSurveyDefinition(SurveyDefinition surveyDefinition)
    throws SurveyServiceException
  {
    try
    {
      // Check if a survey instance exists for the current version of the survey definition
      Query surveyInstanceExistsQuery = entityManager.createQuery(
          "SELECT COUNT(si.id) FROM SurveyInstance si JOIN si.definition sd"
          + " WHERE sd.id = :id AND sd.version = :version");

      surveyInstanceExistsQuery.setParameter("id", surveyDefinition.getId());
      surveyInstanceExistsQuery.setParameter("version", surveyDefinition.getVersion());

      boolean surveyInstanceExists =
          (((Number) surveyInstanceExistsQuery.getSingleResult()).intValue() > 0);

      // Duplicate the survey definition and increment the current version if required
      if (surveyInstanceExists)
      {
        entityManager.detach(surveyDefinition);

        surveyDefinition = surveyDefinition.duplicate();

        surveyDefinition.incrementVersion();
      }

      if (!entityManager.contains(surveyDefinition))
      {
        surveyDefinition = entityManager.merge(surveyDefinition);

        entityManager.flush();

        entityManager.detach(surveyDefinition);
      }

      return surveyDefinition;
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to save the survey definition with ID ("
          + surveyDefinition.getId() + ")", e);
    }
  }

  /**
   * Save the survey instance.
   *
   * @param surveyInstance the survey instance
   *
   * @return the saved survey instance
   *
   * @throws SurveyServiceException
   */
  @Transactional
  public SurveyInstance saveSurveyInstance(SurveyInstance surveyInstance)
    throws SurveyServiceException
  {
    try
    {
      if (!entityManager.contains(surveyInstance))
      {
        surveyInstance = entityManager.merge(surveyInstance);

        entityManager.flush();

        entityManager.detach(surveyInstance);
      }

      return surveyInstance;
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to save the survey instance with ID ("
          + surveyInstance.getId() + ")", e);
    }
  }

  /**
   * Save the survey request.
   *
   * @param surveyRequest the survey request
   *
   * @return the saved survey request
   *
   * @throws SurveyServiceException
   */
  @Transactional
  public SurveyRequest saveSurveyRequest(SurveyRequest surveyRequest)
    throws SurveyServiceException
  {
    try
    {
      if (!entityManager.contains(surveyRequest))
      {
        surveyRequest = entityManager.merge(surveyRequest);

        entityManager.flush();

        entityManager.detach(surveyRequest);
      }

      return surveyRequest;
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to save the survey request with ID ("
          + surveyRequest.getId() + ")", e);
    }
  }

  /**
   * Save the survey response.
   *
   * @param surveyResponse the survey response
   *
   * @return the saved survey response
   *
   * @throws SurveyServiceException
   */
  @Transactional
  public SurveyResponse saveSurveyResponse(SurveyResponse surveyResponse)
    throws SurveyServiceException
  {
    try
    {
      if (!entityManager.contains(surveyResponse))
      {
        surveyResponse = entityManager.merge(surveyResponse);

        entityManager.flush();

        entityManager.detach(surveyResponse);
      }

      return surveyResponse;
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to save the survey response with ID ("
          + surveyResponse.getId() + ")", e);
    }
  }
}
